#!/usr/bin/env bash
# 2025053001

set -e -x

echo "✅ Create wxs"

cat > "$LFMP_DIR_PACKAGED/in/lfmp.wxs" << EOF
<Wix xmlns="http://wixtoolset.org/schemas/v4/wxs">
  <Package
      Codepage="1252"
      InstallerVersion="301"
      Language="1033"
      Manufacturer="Linuxfabrik GmbH"
      Name="Linuxfabrik Monitoring Plugins"
      ProductCode="{7060a355-f73b-447d-aaa8-f4bf2db48032}"
      UpgradeCode="{bb340ae1-12a5-41d3-a27f-8677df3b8032}"
      Version="$LFMP_VERSION">

    <MediaTemplate EmbedCab="yes" />

    <!-- Detect Icinga 2 service via registry; set property if present -->
    <Property Id="ICINGA2_SERVICE_FOUND">
      <RegistrySearch
          Id="Icinga2ServiceReg"
          Root="HKLM"
          Key="SYSTEM\CurrentControlSet\Services\icinga2"
          Name="ImagePath"
          Type="raw"
          Bitness="always64"/>
    </Property>

    <StandardDirectory Id="ProgramFiles64Folder">
      <Directory Id="INSTALL_ROOT" Name="ICINGA2">
        <Directory Id="CM_DP_sbin" Name="sbin">
          <Directory Id="LinuxfabrikDir" Name="linuxfabrik">
            <Files Include="$LFMP_DIR_COMPILED\check-plugins\**" />

            <!-- Only run ServiceControl if the Icinga 2 service exists -->
            <Component Id="Icinga2ServiceControl" Guid="{7e398e63-b894-47d1-9375-eea744988032}">
              <Condition>ICINGA2_SERVICE_FOUND</Condition>
              <ServiceControl
                  Id="icinga2"
                  Name="icinga2"
                  Start="both"
                  Stop="both"
                  Wait="yes"/>
            </Component>

          </Directory>
        </Directory>
      </Directory>
    </StandardDirectory>

  </Package>
</Wix>
EOF
echo $(cat "$LFMP_DIR_PACKAGED/in/lfmp.wxs")

# The above file is WiX v5 syntax. See the older docs:
# * https://docs.firegiant.com/wix3/xsd/wix/product/
# * https://docs.firegiant.com/wix3/xsd/wix/package/
# * https://docs.firegiant.com/wix3/xsd/wix/component/
# and other.

# WIX1148: Invalid MSI package version: '2025022901'. The Windows Installer SDK says that MSI
# package versions must have a major version less than 256, a minor version less than 256,
# and a build version less than 65536. The revision value is ignored but version labels and
# metadata are not allowed. Violating the MSI rules sometimes works as expected but the
# behavior is unpredictable and undefined. Future versions of WiX might treat invalid package
# versions as an error.
