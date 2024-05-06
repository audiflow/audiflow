import 'package:audiflow/ui/app/router/navigator/home_navigator.dart';
import 'package:audiflow/ui/app/router/navigator/library_navigator.dart';
import 'package:audiflow/ui/app/router/navigator/search_navigator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
external HomeNavigator homeNavigator(HomeNavigatorRef ref);

@riverpod
external LibraryNavigator libraryNavigator(LibraryNavigatorRef ref);

@riverpod
external SearchNavigator searchNavigator(SearchNavigatorRef ref);
