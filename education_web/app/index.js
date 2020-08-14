const electron = require('electron');
const path = require('path');

const {ipcMain} = electron;

const { crashReporter } = require('electron');

// const bt = require('backtrace-node');

// workaround for resizable issue in mac os
const platform = require('os').platform();

const process = require('process');
// Module to control application life.
const {app, Menu, netLog} = electron;

// Menu template
const isMac = platform === 'darwin'

const globalShortcut = electron.globalShortcut;
// Module to create native browser window.
const BrowserWindow = electron.BrowserWindow;

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;

async function createWindow() {

    if (process.env.REACT_APP_CRASH_REPORT_URL) {
      crashReporter.start({
        productName: 'eEducation-demo',
        companyName: 'agora-web-electron',
        submitURL: process.env.REACT_APP_CRASH_REPORT_URL,
        uploadToServer: true,
        extra: {
          version: '5.3.2'
        }
      });
    }

    // if (process.env.REACT_APP_BACKTRACE_TOKEN) {
    //   bt.initialize({
    //     endpoint: "",
    //     token: process.env.REACT_APP_BACKTRACE_TOKEN,
    //   });
    // }


    mainWindow = new BrowserWindow({
      frame: false,
      width: 700,
      height: 500,
      center: true,
      resizable: false,
      show: false,
      webPreferences: {
        autoplayPolicy: 'no-user-gesture-required',
        nodeIntegration: true,
        preload: path.join(__dirname, './preload')
      }
    });

    const startUrl = process.env.ELECTRON_START_URL || 
    `file://${path.resolve(
      __dirname,
      '../../app.asar/build'
    )}/index.html`;

    mainWindow.center();

    // and load the index.html of the app.
    mainWindow.loadURL(startUrl);

    const appLogPath = app.getPath('logs')

    const logPath = path.join(appLogPath, `log`, `agora_sdk.log`)
    const dstPath = path.join(appLogPath, `log`, `agora_sdk.log.zip`)
    const videoSourceLogPath = path.join(appLogPath, `log`, `video_source_agora_sdk.log`)
    const videoSourceAddonLogPath = path.join(appLogPath, `log`, `video_source_addon_agora_sdk.log`)

    mainWindow.webContents.on("did-finish-load", (event, args) => {
      event.sender.webContents.send('appPath', [appLogPath, videoSourceLogPath])
    })

    mainWindow.webContents.once("did-finish-load", () => {
      mainWindow.webContents.send('initialize', [logPath, dstPath, videoSourceLogPath, videoSourceAddonLogPath])
    })

    mainWindow.webContents.on('new-window', (event, url, frameName, disposition, options, additionalFeatures) => {
    })

    // Emitted when the window is closed.
    mainWindow.on('closed', function () {
        // Dereference the window object, usually you would store windows
        // in an array if your app supports multi windows, this is the time
        // when you should delete the corresponding element.
        const currentWindow = BrowserWindow.getFocusedWindow()
        if (currentWindow === mainWindow) {
          mainWindow = null
        }
        // mainWindow = null
    })

    mainWindow.once('ready-to-show', () => {
      mainWindow.show();
    })

    // TODO: electron menu template
    // More details please see: https://www.electronjs.org/docs/api/menu#menubuildfromtemplatetemplate
    const template = [
      // { role: 'appMenu' }
      ...(isMac ? [{
        label: app.name,
        submenu: [
          // { role: 'about' },
          { type: 'separator' },
          { role: 'services' },
          { type: 'separator' },
          { role: 'hide' },
          { role: 'hideothers' },
          { role: 'unhide' },
          { type: 'separator' },
          { role: 'quit' }
        ]
      }] : []),
      // { role: 'fileMenu' }
      {
        label: 'File',
        submenu: [
          isMac ? { role: 'close' } : { role: 'quit' }
        ]
      },
      // { role: 'editMenu' }
      {
        label: 'Edit',
        submenu: [
          { role: 'undo' },
          { role: 'redo' },
          { type: 'separator' },
          { role: 'cut' },
          { role: 'copy' },
          { role: 'paste' },
          ...(isMac ? [
            { role: 'pasteAndMatchStyle' },
            { role: 'delete' },
            { role: 'selectAll' },
            { type: 'separator' },
            {
              label: 'Speech',
              submenu: [
                { role: 'startspeaking' },
                { role: 'stopspeaking' }
              ]
            }
          ] : [
            { role: 'delete' },
            { type: 'separator' },
            { role: 'selectAll' }
          ])
        ],
      },
      // { role: 'viewMenu' }
      {
        label: 'View',
        submenu: [
          { role: 'reload' },
          { role: 'forcereload' },
          { role: 'toggledevtools' },
          { type: 'separator' },
          { role: 'resetzoom' },
          { role: 'zoomin' },
          { role: 'zoomout' },
          { type: 'separator' },
          { role: 'togglefullscreen' }
        ]
      },
      // { role: 'windowMenu' }
      {
        label: 'Window',
        submenu: [
          { role: 'minimize' },
          { role: 'zoom' },
          ...(isMac ? [
            { type: 'separator' },
            { role: 'front' },
            { type: 'separator' },
            { role: 'window' }
          ] : [
            { role: 'close' }
          ])
        ]
      },
      {
        label: 'Log',
        submenu: [
          {
            label: 'export log',
            click: async () => {
              mainWindow.webContents.send("export-log", [logPath, dstPath])
            }
          }
        ]
      },
      {
        label: 'About Agora',
        submenu: [
          {
            label: 'more info',
            click: async () => {
              const { shell } = require('electron')
              await shell.openExternal('https://www.agora.io')
            }
          }
        ]
      }
    ]

    const menu = Menu.buildFromTemplate(template)

    if (platform === 'darwin') {
      mainWindow.excludedFromShownWindowsMenu = true
      Menu.setApplicationMenu(menu)
    }

    if (platform === 'win32') {
      // const menu = Menu.buildFromTemplate(template)
      // Menu.setApplicationMenu(menu)
      mainWindow.setMenu(menu);
    }

    ipcMain.on('resize-window', (event, reply) => {
      const currentWindow = BrowserWindow.getFocusedWindow() || mainWindow
      
      if (platform === 'darwin') {
        if (reply.width === 700) {
          currentWindow.setResizable(true);
          currentWindow.setFullScreen(false);
          currentWindow.setContentSize(reply.width, reply.height, false);
          currentWindow.center();
          currentWindow.setResizable(false);
          return;
        }
      }

      if (platform === 'win32') {
        if (reply.width === 700) {
          if (currentWindow.isFullScreen()) {
            currentWindow.setResizable(true);
            currentWindow.setFullScreen(false);
            currentWindow.setResizable(false);
          }
        }
      }

      currentWindow.setContentSize(reply.width, reply.height, false);
      currentWindow.center();
    });

    ipcMain.on('minimum', (event) => {
      const currentWindow = BrowserWindow.getFocusedWindow()
      currentWindow.minimize();
    });

    ipcMain.on('maximum', () => {
      const currentWindow = BrowserWindow.getFocusedWindow()

      if (platform === 'win32') {
        const fullscreen = currentWindow.isFullScreen();
        if (fullscreen) {
          currentWindow.setResizable(true);
          currentWindow.setFullScreen(false);
          currentWindow.setResizable(false);
        } else {
          currentWindow.setResizable(true);
          currentWindow.setFullScreen(true);
          currentWindow.setResizable(false);
        }
      }

      if (platform === 'darwin') {
        const fullscreen = currentWindow.isFullScreen();
        currentWindow.setFullScreen(!fullscreen);
      }
    });

    ipcMain.on('close', () => {
      const currentWindow = BrowserWindow.getFocusedWindow() || mainWindow
      if (currentWindow === mainWindow) {
        app.quit()
        return;
      }
      currentWindow.close()
    });
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow);


app.whenReady().then(() => {
  // more details: https://www.electronjs.org/docs/tutorial/keyboard-shortcuts
  globalShortcut.register('Control+Shift+X', () => {
    // Open the DevTools.
    const currentWindow = BrowserWindow.getFocusedWindow()
    currentWindow.webContents.openDevTools();
  })
});

// Quit when all windows are closed.
app.on('window-all-closed', function () {
    // On OS X it is common for applications and their menu bar
    // to stay active until the user quits explicitly with Cmd + Q
    if (process.platform !== 'darwin') {
      app.quit()
    }
});

app.on('activate', function () {
    console.log("main process activate");
    // On OS X it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (mainWindow === null) {
      createWindow()
    }

    if (mainWindow) {
      mainWindow.show();
    }
});

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.