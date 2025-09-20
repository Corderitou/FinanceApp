import '../../../domain/entities/work_location.dart';
import '../../../data/repositories/work_location_repository.dart';

class UpdateWorkLocationUsecase {
  final WorkLocationRepository _workLocationRepository;

  UpdateWorkLocationUsecase(this._workLocationRepository);

  Future<WorkLocation> execute(WorkLocation workLocation) async {
    return await _workLocationRepository.updateWorkLocation(workLocation);
  }
}