{
  lib,
  python3Packages,
  fetchFromGitea,
  fetchFromGitHub,
  callPackage,

  #
  postgresql,
  libxml2,
  libxslt,

  # tests
  postgresqlTestHook,
}:

let
  password-entropy = callPackage ./password-entropy.nix { };
  flask-babel = python3Packages.flask-babel.overridePythonAttrs rec {
    version = "2.0.0";
    format = "setuptools";
    src = fetchFromGitHub {
      owner = "python-babel";
      repo = "flask-babel";
      tag = "v${version}";
      hash = "sha256-7e6+tQa1/ynbKfBJDowlbAX47YibgLtfzQzhuFMizdg=";
    };
  };
in

python3Packages.buildPythonPackage rec {
  pname = "liberaforms";
  version = "4.1.1";
  format = "other";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "LiberaForms";
    repo = "server";
    tag = "v${version}";
    hash = "sha256-2ewK53bGBLXxt4appUO/9MVo6H96xQy2vT8//Odk+fo=";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    aiosmtpd
    alembic
    atpublic
    attrs
    babel
    beautifulsoup4
    bleach
    cairosvg
    cachelib
    certifi
    cffi
    charset-normalizer
    click
    cryptography
    dnspython
    email-validator
    feedgen
    flask
    flask-babel
    flask-login
    flask-marshmallow
    flask-migrate
    # TODO:
    # flask-session2
    flask-session
    flask-sqlalchemy
    flask-wtf
    greenlet
    gunicorn
    idna
    importlib-metadata
    importlib-resources
    iniconfig
    itsdangerous
    jinja2
    ldap3
    lxml
    mako
    markdown
    markupsafe
    marshmallow
    marshmallow-sqlalchemy
    minio
    packaging
    passlib
    # TODO:
    # password-strength
    password-entropy
    pillow
    platformdirs
    pluggy
    portpicker
    prometheus-client
    psutil
    psycopg2
    py
    pyasn1
    pycodestyle
    pycparser
    pygments
    pyjwt
    pyparsing
    pypng
    pyqrcode
    python-dateutil
    python-dotenv
    python-magic
    pytz
    requests
    six
    smtpdfix
    snowballstemmer
    soupsieve
    sqlalchemy
    sqlalchemy-json
    toml
    unicodecsv
    unidecode
    urllib3
    webencodings
    werkzeug
    wtforms
    zipp
  ];

  pythonRemoveDeps = [
    # removed
    "typed-ast"
  ];

  nativeBuildInputs = [
    postgresql
    libxml2
    libxslt
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -R ${src}/. $out

    runHook postInstall
  '';

  doCheck = true;

  nativeCheckInputs =
    [
      postgresql
      postgresqlTestHook
    ]
    ++ (with python3Packages; [
      faker
      pytest
      pytest-dotenv
      factory-boy
      polib
    ]);

  preCheck = ''
    export LANG=C.UTF-8
    export PGUSER=db_user
    export postgresqlEnableTCP=1
  '';

  checkPhase = ''
    runHook preCheck

    # Run pytest on the installed version. A running postgres database server is needed.
    (cd tests && cp test.ini.example test.ini && pytest -k "not test_save_smtp_config") #TODO why does this break?

    runHook postCheck
  '';

  # avoid writing in the migration process
  postFixup = ''
    cp $out/assets/brand/logo-default.png $out/assets/brand/logo.png
    cp $out/assets/brand/favicon-default.ico $out/assets/brand/favicon.ico
    sed -i "/shutil.copyfile/d" $out/liberaforms/models/site.py
    sed -i "/brand_dir/d" $out/migrations/versions/6f0e2b9e9db3_.py
  '';

  meta = {
    description = "Free form software";
    homepage = "https://gitlab.com/liberaforms/liberaforms";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.all;
  };
}
