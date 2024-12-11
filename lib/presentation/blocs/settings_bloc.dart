import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stpvelox/domain/entities/setting.dart';
import 'package:stpvelox/domain/usecases/update_setting.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final UpdateSetting updateSetting;

  SettingsBloc({required this.updateSetting}) : super(SettingsInitial()) {
    on<LoadSettingsEvent>((event, emit) async {
      emit(SettingsLoading());
      try {
                final settings = await updateSetting.repository.getSettings();
        emit(SettingsLoaded(settings: settings));
      } catch (e) {
        emit(SettingsError(message: e.toString()));
      }
    });

    on<SettingTappedEvent>((event, emit) async {
      emit(SettingsLoading());
      try {
        await updateSetting.execute(event.label);
                        add(LoadSettingsEvent());
      } catch (e) {
        emit(SettingsError(message: e.toString()));
      }
    });
  }
}