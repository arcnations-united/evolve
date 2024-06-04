# Evolve

The powerful and modern alternative to Gnome Tweaks with GTK-4.0 support and some cool features

## Evolve - A brand new GNOME Theme Manager
![1](https://github.com/arcnations-united/evolve/assets/114287507/4a9c19b2-afb9-422d-aabd-401c6ecae3c8)

Themes

As you would expect, it has all the obvious theming features of Gnome Tweaks minus the fonts part. You can change the GTK Theme, change icons and more. What Tweaks does not support as of now is GTK 4 theming and this is where Evolve starts to make a difference.

![2](https://github.com/arcnations-united/evolve/assets/114287507/cdd4d19c-4fbc-425a-bf5f-cc585da78922)

Evolve provides you not only with complete GTK 4 support but also Global Themes which take care of everything starting from applying gtk-3.0 theme, gnome-shell theme and even gtk-4.0 theme. Applying a Global Theme applies to Evolve itself and if you like the colours, you can go ahead and apply it system wide!

![3](https://github.com/arcnations-united/evolve/assets/114287507/99f3c98a-2ae0-448b-bbef-7f96c18998ae)

Evolve also allows you to create your own new Global Theme by mixing and matching different gtk3, gtk4 and gnome-shell themes together. You can name it whatever you feel like and even change the colours associated with the theme. Evolve even marks the most important colours - foreground and background so that you can edit them first to get an idea of what you theme would look like. (Look below)

![4](https://github.com/arcnations-united/evolve/assets/114287507/987349ce-bcfb-43ed-830f-a046d91cfc94)

Although modifying colours are mostly safe and tested a number of times by me, you never know when problems happen! So modifying the colours won't change the original theme you are modifying, instead the colours would be applied to the app itself and if something goes wrong, just hit reset to rollback the changes. You might get tired while changing all the colours, so you may take breaks and close the app. When you re-open it, the colours remain intact.

![5](https://github.com/arcnations-united/evolve/assets/114287507/600171f4-cf31-4711-b800-cc2f2f281c20)

When you are confident about your new theme, apply it system wide. Done!

# Icons

Okay now let us talk about icon-packs which have a separate section cuz they deserve a separate section! When you have a large list of icon packs installed, it is quite inconvenient to remember which icon pack looks like what. To solve this we have a brand new UI which shows icons of some of the default apps on Gnome along with the icon-pack name.

![6](https://github.com/arcnations-united/evolve/assets/114287507/8338e754-518c-4fa1-a2df-6a2157fae514)

But did you notice the icon mentioned that it "may be" corrupted? Well Evolve also has better error handling making sure that the theme you are trying to apply actually works and does not behave weird for not having all of the icons. If you still try to apply a corrupted theme you will get another warning message before you apply the icon pack.

![7](https://github.com/arcnations-united/evolve/assets/114287507/9a6846b4-7416-4837-b69a-98c341e53f52)

Now what if you don't have the .icons folder or any other icon folder like in .local/share/icons

Well you can create the folder from the app itself! The same goes for the .themes folder in home.

![8](https://github.com/arcnations-united/evolve/assets/114287507/2a271b91-d047-4800-842c-fa20c3ee27d6)

# Backing up themes
![9](https://github.com/arcnations-united/evolve/assets/114287507/09cf94cc-870e-4ebf-9954-a46d5bb1e58e)

Evolve maintains a config.zip file that contains all the necessary data to replicate your exact look and theme on another PC or a freshly installed OS. You can back up all the data you need or exclude specific information if you prefer.

Evolve also supports auto-backup, automatically saving your data every time you load the application!

![10](https://github.com/arcnations-united/evolve/assets/114287507/9fc9972c-ae4d-4cad-a195-89ec5036d46c)

Installing the config is super easy and offers a ton of options. You can replicate the entire config on your system, leave out parts of it, replace the existing files on your system (recommended), or safely append them to the existing files (not well tested).

# Extensions

![11](https://github.com/arcnations-united/evolve/assets/114287507/d4349c72-eb2f-4968-b854-565e261d2143)

One app for all needs.

Evolve now serves as your all-in-one solution. It can seamlessly manage installed extensions, allowing you to toggle them on/off and effortlessly install new ones. 

You need not have a separate app for managing gnome shell extensions.

![12](https://github.com/arcnations-united/evolve/assets/114287507/13d8068b-8881-474a-8c4a-f0a420fa6ab9)

Each extension has its own page which allows you to install/uninstall an extension or open the preferences window of the specific shell extension. Unsupported extensions can be viewed too on this page which shows that the extension is incompatible.

![13](https://github.com/arcnations-united/evolve/assets/114287507/a47d7608-3417-41c9-b28b-37167c340f99)

# Performance Updates

Backup involves copying files, accessing system information, and packing them into a zip, which are resource-intensive tasks when run on a single thread. Auto-backup runs these tasks when Evolve launches, which could negatively affect its performance. To address this, the process is run in an isolate, which takes the process to a different thread so that the UI renders smoothly.

When you manually update, the method runs separately to enable the progress bar, but the UI may freeze to prevent memory leaks. Background backup does not freeze the UI and runs the update in the background. However, closing the app will stop the process and may corrupt the configuration.

Surfing the Extensions page often fetches large JSON files from the internet to show results. This is also run in an isolate, keeping the UI super smooth!

Installing extensions are much, MUCH faster with Evolve. Pages load up quicker than the official gnome-extensions website! You will love how fluid everything is. 😉

Other changes

Evolve now applies the GTK theme to itself with greater precision. Colors are more accurately fetched and applied, resulting in a refined appearance.

Additionally, it generates a new Material theme based on the colors of the applied GTK theme. This ensures that app components, which aren't themed separately, seamlessly blend in rather than appearing out of place.

All new AdaptiveList widget lays out widgets based on available size. Changes axis of the widget list layout automatically with smooth fluid animations.


## Getting Started

Download the release build from here -
https://github.com/arcnations-united/evolve/releases

Get access to alpha builds and support development -
https://www.patreon.com/arcnations
