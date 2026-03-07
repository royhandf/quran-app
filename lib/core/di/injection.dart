import 'package:get_it/get_it.dart';
import 'package:quran_app/core/services/location_service.dart';
import '../services/api_service.dart';
import '../../data/repositories/quran_repository.dart';
import '../../data/repositories/prayer_repository.dart';
import '../../data/local/hive_service.dart';
import '../../presentation/blocs/quran/quran_cubit.dart';
import '../../presentation/blocs/prayer/prayer_cubit.dart';
import '../../presentation/blocs/bookmark/bookmark_cubit.dart';
import '../../presentation/blocs/settings/settings_cubit.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<HiveService>(() => HiveService());

  getIt.registerLazySingleton<QuranRepository>(
    () => QuranRepository(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<PrayerRepository>(
    () => PrayerRepository(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<LocationService>(() => LocationService());

  getIt.registerFactory<QuranCubit>(() => QuranCubit(getIt<QuranRepository>()));
  getIt.registerFactory<PrayerCubit>(
    () => PrayerCubit(
      getIt<PrayerRepository>(),
      getIt<LocationService>(),
      getIt<HiveService>(),
    ),
  );
  getIt.registerFactory<BookmarkCubit>(
    () => BookmarkCubit(getIt<HiveService>()),
  );
  getIt.registerFactory<SettingsCubit>(
    () => SettingsCubit(getIt<HiveService>()),
  );
}
