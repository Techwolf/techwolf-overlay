# Gentoo Overlay Project

Primary purpose is for Second Life with the following added:

*   Working streaming media on 64-bit systems.
*   Working vivox on 64-bit builds.
*   Spacenav 3D joystick support.
*   Many build fixes, no more stupid gcc errors that prevent builds.
*   Some pjira bugfix patches.
*   Some pjira feature add patches.
*   A few third party patches that are useful to the everyday user while not interfering with the existing User Interface. IE:One can not or turn off the feature within the client.

* * *

## To use my overlay

As root:

`layman -f -a techwolf -o 'http://techwolf.github.io/overlays.xml'`

Or if using paludis:

`playman --layman-url http://techwolf.github.io/overlays.xml -a techwolf`

`"emerge -av secondlife"` for the main client
or
`"emerge -av firestorm-hg"` for the firestorm client

The secondlife package (that is no longer) provided by portage differs from this overlay:

*   No voice support in the portage provided ebuild.
*   No USE flags support for vivox, openal, webkit, gstreamer, fmod, or dbus in the portage provided ebuild.
*   Joystick INTENDEDLY disabled in the portage provided ebuild. This includes all joysticks, including the spacenav 3D joystick.
*   The ebuilds in this overlay provide full joystick support, voice support, USE flag support.

* * *

## Optional USE flags

*   openal: Enable the openal soft sound system, default on.
*   vivox: Enable the voice support. This binary requires some 32-bit libs on 64-bit system. The 64-bit build of the Secondlife can use the 32-bit vivox binary. Default on.
*   fmod: Enable the fmod sound support, default off.
*   llwebkit: Enable the qt-webkit support. Disabling this may reduce some search functions within the Secondlife client. Default on.
*   dbus: Enable or disable the dbus.

* * *

## Other secondlife programs

There are other secondlife related programs in this overlay.

*   Firestorm
This is a homebrewn viewer which adds new functionality to the viewer with the intent of easing the users interaction with the environment. Popular with powerusers and l33t users.
[http://www.firestormviewer.org/](http://www.firestormviewer.org/)  `"emerge -av firestorm-hg"`

*   Imprudence
 Metaverse (SL) viewer with an emphasis on usability and bold changes.
[http://imprudenceviewer.org/](http://imprudenceviewer.org/)

Non-3D GUI clients, for when you just need to chat and other things that don't need a full 3D GUI view.

*   Radegast and Radegast-svn <span class="s q">Text only client.</span>
[http://radegastclient.org/wp/](http://radegastclient.org/wp/)

*   Slitechat <span class="s q">A Lite IM/Chat Client for Second Life</span>
[http://slitechat.dooglio.net/](http://slitechat.dooglio.net/)

* * *

## LL CMS Branches

There is several mercurial branches from Linden Labs and third party viewers. They are:

*   secondlife-hg is a live hg pull from a viewer development or release canidate repro. This repro is being maintained by LL and the open source community.
*   firestorm-hg is a live hg pull from the phoenix viewer project of Linden Labs viewer 2/3.x based code.
*   All branches do a live pull from the hg repository, to update, just re-emerge them.
*   All can be installed at the same time.
*   To run the client, just use the menu or from the command line, secondlife or phoenix-hg or firestorm-hg for the client you wish to run.

* * *

## 3Dconnexion's SpaceNavigator

3Dconnexion's SpaceNavigator users may need to do the following:

1.  Uninstall any 3Dconnexion company supplied linux drivers as they conflict with the one built into the kernel. The SpaceNavigator shows up as a HID device that Secondlife can use.
2.  Create some udev rules if they are not supplied with the distro. Currently gentoo does not.

    ```Shell
cat << EOF > /etc/udev/rules.d/91-spacenavigator.rules
KERNEL=="event[0-9]*", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c603", SYMLINK+="input/spacemouse", GROUP="plugdev", MODE="664"
KERNEL=="event[0-9]*", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c623", SYMLINK+="input/spacetraveler", GROUP="plugdev", MODE="664"
KERNEL=="event[0-9]*", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c626", SYMLINK+="input/spacenavigator", GROUP="plugdev", MODE="664"
EOF
    ```

3.  Create some hal policy rules to prevent the SpaceNavigator from being used as a mouse with hotpluggin on x-org. Only needed if you find the joystick controlling the mouse.

    ```Shell
    cat << EOF > /etc/hal/fdi/policy/3Dconnexion_SpaceNavigator.fdi
    <?xml version="1.0" encoding="ISO-8859-1"?>
    <deviceinfo version="0.2">
      <device>
        <match key="info.product" contains="3Dconnexion SpaceNavigator">
          <merge key="input.x11_driver" type="string"></merge>
        </match>
      </device>
    </deviceinfo>
    EOF
    ```
