package com.reedom.audiflow_app

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import java.io.File
import java.io.FileNotFoundException

/**
 * Serves the artwork Dart prepares under the app cache to media hosts
 * outside the app, which load artwork only through `content:` URIs: the
 * Android Auto browse rows (`car_artwork`) and the media session's
 * now-playing artwork (`now_playing_artwork`), which Android Auto, Android
 * Automotive and System UI read. URIs take the form `/<folder>/<file>`.
 *
 * Exported so those hosts can read it without a URI grant. It is
 * read-only, serves only files named like the Dart preparer's output (an
 * MD5 hex name and `.png`) from those folders, and never fetches anything,
 * so another app can read public podcast artwork at most.
 */
class CarArtworkProvider : ContentProvider() {
  override fun onCreate(): Boolean = true

  override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor {
    if (mode != "r") throw SecurityException("Artwork is read-only")
    val segments = uri.pathSegments
    if (segments.size != 2) throw FileNotFoundException(uri.toString())
    val (folder, name) = segments
    if (folder !in FOLDERS || !FILE_NAME.matches(name)) throw FileNotFoundException(uri.toString())
    val context = context ?: throw FileNotFoundException(uri.toString())
    val file = File(File(context.cacheDir, folder), name)
    if (!file.isFile) throw FileNotFoundException(uri.toString())
    return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
  }

  override fun getType(uri: Uri): String = "image/png"

  override fun query(
    uri: Uri,
    projection: Array<out String>?,
    selection: String?,
    selectionArgs: Array<out String>?,
    sortOrder: String?,
  ): Cursor? = null

  override fun insert(uri: Uri, values: ContentValues?): Uri? = null

  override fun update(
    uri: Uri,
    values: ContentValues?,
    selection: String?,
    selectionArgs: Array<out String>?,
  ): Int = 0

  override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0

  private companion object {
    /**
     * Must match `carArtworkCacheFolder` in `car_artwork_resolver.dart` and
     * `nowPlayingArtworkCacheFolder` in `now_playing_artwork_provider.dart`.
     */
    val FOLDERS = setOf("car_artwork", "now_playing_artwork")
    val FILE_NAME = Regex("[0-9a-f]{32}\\.png")
  }
}
