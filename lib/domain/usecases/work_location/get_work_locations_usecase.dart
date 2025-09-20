import '../../../domain/entities/work_location.dart';
import '../../../data/repositories/work_location_repository.dart';

class GetWorkLocationsUsecase {
  final WorkLocationRepository _workLocationRepository;

  GetWorkLocationsUsecase(this._workLocationRepository);

  Future<List<WorkLocation>> execute(int userId) async {
    return await _workLocationRepository.getWorkLocationsByUserId(userId);
  }
}