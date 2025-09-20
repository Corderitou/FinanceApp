import '../../../domain/entities/work_location.dart';
import '../../../data/repositories/work_location_repository.dart';

class CreateWorkLocationUsecase {
  final WorkLocationRepository _workLocationRepository;

  CreateWorkLocationUsecase(this._workLocationRepository);

  Future<WorkLocation> execute(WorkLocation workLocation) async {
    return await _workLocationRepository.addWorkLocation(workLocation);
  }
}