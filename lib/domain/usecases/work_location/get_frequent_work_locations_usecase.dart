import '../../../domain/entities/work_location.dart';
import '../../../data/repositories/work_location_repository.dart';

class GetFrequentWorkLocationsUsecase {
  final WorkLocationRepository _workLocationRepository;

  GetFrequentWorkLocationsUsecase(this._workLocationRepository);

  Future<List<WorkLocation>> execute(int userId, {int limit = 5}) async {
    return await _workLocationRepository.getFrequentWorkLocationsByUserId(userId, limit: limit);
  }
}