{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "password-entropy";
  version = "1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "alistratov";
    repo = "password-entropy-py";
    rev = version;
    hash = "sha256-w721Y/zRMH3fsU0XtaGSDoj1GKqOW/IOGUfimoq4r2E=";
  };

  build-system = with python3Packages; [
    flit-core
  ];

  pythonImportsCheck = [
    "data_password_entropy"
  ];

  meta = {
    description = "Calculate password strength";
    homepage = "https://github.com/alistratov/password-entropy-py";
    license = lib.licenses.asl20;
  };
}
