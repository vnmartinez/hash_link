part of 'generate_key_bloc.dart';

sealed class GenerateKeyEvent {}

@blocEvent
class NextStep extends GenerateKeyEvent with _$NextStep {
  const factory NextStep() = _NextStep;
}

@blocEvent
class PreviousStep extends GenerateKeyEvent with _$PreviousStep {
  const factory PreviousStep() = _PreviousStep;
}

@blocEvent
class GenerateRSAKeyPair extends GenerateKeyEvent with _$GenerateRSAKeyPair {
  const factory GenerateRSAKeyPair() = _GenerateRSAKeyPair;
}

@blocEvent
class GenerateAESSymmetricKey extends GenerateKeyEvent
    with _$GenerateAESSymmetricKey {
  const factory GenerateAESSymmetricKey() = _GenerateAESSymmetricKey;
}