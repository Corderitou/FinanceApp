import '../../../domain/entities/work_location.dart';
import '../../../data/repositories/work_location_repository.dart';

class GetWorkLocationByIdUsecase {
  final WorkLocationRepository _workLocationRepository;

  GetWorkLocationByIdUsecase(this._workLocationRepository);

  Future<WorkLocation?> execute(int id) async {
    return await _workLocationRepository.getWorkLocationById(id);
  }
}