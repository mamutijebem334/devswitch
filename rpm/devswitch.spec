Name:           devswitch
Version:        1.0.0
Release:        1%{?dist}
Summary:        Developer profile switcher

License:        MIT
URL:            https://github.com/GustyCube/devswitch
Source0:        https://github.com/GustyCube/devswitch/releases/download/v%{version}/devswitch-linux-amd64

BuildArch:      x86_64
Requires:       glibc

%description
DevSwitch allows you to instantly switch developer profiles
(.gitconfig, shell rc, VSCode settings) across work/school/personal setups.
Features include automatic backups, profile comparison, templates,
and support for SSH keys, environment variables, Docker, NPM, and AWS configs.

%prep
# No preparation needed for binary release

%build
# No build needed for binary release

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{_bindir}
cp %{SOURCE0} $RPM_BUILD_ROOT%{_bindir}/devswitch
chmod 755 $RPM_BUILD_ROOT%{_bindir}/devswitch

%files
%{_bindir}/devswitch

%changelog
* Thu Aug 07 2025 DevSwitch Team <support@devswitch.dev> - 1.0.0-1
- Initial release of DevSwitch CLI
- Instant profile switching for developer configurations
- Beautiful CLI with styled boxes and progress bars
- Automatic backup and rollback system
- Profile comparison and selective apply
- Template system (corporate, personal, minimal)
- Extended configuration support for Git, SSH, Docker, NPM, AWS