{ stdenv, fetchFromGitHub, fetchpatch, pantheon, pkgconfig, meson, python3
, ninja, substituteAll, vala, gtk3, granite, wingpanel, evolution-data-server
, libical, libgee, libxml2, libsoup, gobject-introspection
, elementary-calendar, elementary-icon-theme, wrapGAppsHook }:

stdenv.mkDerivation rec {
  pname = "wingpanel-indicator-datetime";
  version = "2.1.3";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = pname;
    rev = version;
    sha256 = "1y7a4xjwl3bpls56ys6g3s6mh5b3qbjm2vw7b6n2i4x7a63c4cbh";
  };

  passthru = {
    updateScript = pantheon.updateScript {
      repoName = pname;
    };
  };

  nativeBuildInputs = [
    gobject-introspection
    libxml2
    meson
    ninja
    pkgconfig
    python3
    vala
    wrapGAppsHook
  ];

  buildInputs = [
    elementary-icon-theme
    evolution-data-server
    granite
    gtk3
    libgee
    libical
    libsoup
    wingpanel
  ];

  patches = [
    (substituteAll {
      src = ./calendar-exec.patch;
      elementary-calendar = "${elementary-calendar}/bin/io.elementary.calendar";
    })
    # Use "clock-format" GSettings key that's been moved to granite
    (fetchpatch {
      url = "https://src.fedoraproject.org/rpms/wingpanel-indicator-datetime/raw/c8d515b76aa812c141212d5515621a6febd781a3/f/00-move-clock-format-settings-to-granite.patch";
      sha256 = "1sq3aw9ckkm057rnrclnw9lyrxbpl37fyzfnbixi2q3ypr70n880";
    })
  ];

  PKG_CONFIG_WINGPANEL_2_0_INDICATORSDIR = "lib/wingpanel";

  postPatch = ''
    chmod +x meson/post_install.py
    patchShebangs meson/post_install.py
  '';

  meta = with stdenv.lib; {
    description = "Date & Time Indicator for Wingpanel";
    homepage = https://github.com/elementary/wingpanel-indicator-datetime;
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = pantheon.maintainers;
  };
}
