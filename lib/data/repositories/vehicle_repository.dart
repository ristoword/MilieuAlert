import '../../models/vehicle.dart';
import '../database/daos/vehicle_dao.dart';

class VehicleRepository {
  final VehicleDao _vehicleDao;

  VehicleRepository({required this._vehicleDao});

  Future<Vehicle?> getActiveVehicle() => _vehicleDao.getActiveVehicle();

  Future<int> saveVehicle(Vehicle vehicle) =>
      _vehicleDao.insertVehicle(vehicle);

  Future<void> updateVehicle(Vehicle vehicle) =>
      _vehicleDao.updateVehicle(vehicle);
}
