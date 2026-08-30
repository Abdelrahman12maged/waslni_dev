import 'dart:io';
import 'package:equatable/equatable.dart';

class DriverSignupInitialData extends Equatable {
  final String name;
  final String mobile;
  final String password;
  final File? driverImage;

  // Vehicle info
  final String? carType;
  final String? carModel;
  final String? seats;
  final String? plateNumber;

  // Vehicle photos
  final File? drivingLic;
  final File? insidePicture;
  final File? outsidePicture;

  // KYC documents
  final File? nationalId;
  final File? criminalRecord;
  final File? vehicleLicense;

  const DriverSignupInitialData({
    required this.name,
    required this.mobile,
    required this.password,
    this.driverImage,
    this.carType,
    this.carModel,
    this.seats,
    this.plateNumber,
    this.drivingLic,
    this.insidePicture,
    this.outsidePicture,
    this.nationalId,
    this.criminalRecord,
    this.vehicleLicense,
  });

  DriverSignupInitialData copyWith({
    String? name,
    String? mobile,
    String? password,
    File? driverImage,
    String? carType,
    String? carModel,
    String? seats,
    String? plateNumber,
    File? drivingLic,
    File? insidePicture,
    File? outsidePicture,
    File? nationalId,
    File? criminalRecord,
    File? vehicleLicense,
  }) {
    return DriverSignupInitialData(
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      password: password ?? this.password,
      driverImage: driverImage ?? this.driverImage,
      carType: carType ?? this.carType,
      carModel: carModel ?? this.carModel,
      seats: seats ?? this.seats,
      plateNumber: plateNumber ?? this.plateNumber,
      drivingLic: drivingLic ?? this.drivingLic,
      insidePicture: insidePicture ?? this.insidePicture,
      outsidePicture: outsidePicture ?? this.outsidePicture,
      nationalId: nationalId ?? this.nationalId,
      criminalRecord: criminalRecord ?? this.criminalRecord,
      vehicleLicense: vehicleLicense ?? this.vehicleLicense,
    );
  }

  @override
  List<Object?> get props => [
        name,
        mobile,
        password,
        driverImage,
        carType,
        carModel,
        seats,
        plateNumber,
        drivingLic,
        insidePicture,
        outsidePicture,
        nationalId,
        criminalRecord,
        vehicleLicense,
      ];
}
