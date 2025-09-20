import '../../../data/repositories/work_location_repository.dart';

class DeleteWorkLocationUsecase {
  final WorkLocationRepository _workLocationRepository;

  DeleteWorkLocationUsecase(this._workLocationRepository);

  Future<void> execute(int id) async {
    return await _workLocationRepository.deleteWorkLocation(id);
  }
}