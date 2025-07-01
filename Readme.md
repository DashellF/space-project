Hello! To run this, you will need a couple things installed, including

- Godot (4.x.x)
- Android Studio (for the android feature, unnecessary for desktop feature)
- Java sdk version 17 (https://adoptium.net/temurin/releases?version=17&os=any&arch=any) (also for the android feature, unnecessary for desktop)
- An android vm, downloadable from android studio



To run this app on desktop, simply run:

git clone https://github.com/DashellF/space-project

into windows command prompt or linux shell. Then, you can open this project through godot. After opening, click the triangle on the top right of the editor to run the game.

To run this app on an android vm (virtual machine): download all dependencies listed above, list your filepaths in godot's editor settings for sdk files of both android and java. Then, download godot's newest android build template, and export the project as an android apk.
After getting the .apk file, drag and drop that file into your running android vm, and android studio will do the rest! Just open up the app on your home screen when it is done importing.
