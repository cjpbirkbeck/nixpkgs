{ stdenv, fetchFromGitHub, makeWrapper
, libaio, python, zlib
, withGnuplot ? false, gnuplot ? null }:

stdenv.mkDerivation rec {
  pname = "fio";
  version = "3.20";

  src = fetchFromGitHub {
    owner  = "axboe";
    repo   = "fio";
    rev    = "fio-${version}";
    sha256 = "1ahdcyrj7jgm4qx5s0q7gvbpqr2w57psazsf0wswp1v3mb9w4zg4";
  };

  buildInputs = [ python zlib ]
    ++ stdenv.lib.optional (!stdenv.isDarwin) libaio;

  nativeBuildInputs = [ makeWrapper ];

  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace Makefile \
      --replace "mandir = /usr/share/man" "mandir = \$(prefix)/man" \
      --replace "sharedir = /usr/share/fio" "sharedir = \$(prefix)/share/fio"
    substituteInPlace tools/plot/fio2gnuplot --replace /usr/share/fio $out/share/fio
  '';

  postInstall = stdenv.lib.optionalString withGnuplot ''
    wrapProgram $out/bin/fio2gnuplot \
      --prefix PATH : ${stdenv.lib.makeBinPath [ gnuplot ]}
  '';

  meta = with stdenv.lib; {
    description = "Flexible IO Tester - an IO benchmark tool";
    homepage = "https://git.kernel.dk/cgit/fio/";
    license = licenses.gpl2;
    platforms = platforms.unix;
  };
}
