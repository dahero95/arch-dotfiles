const { app, BrowserWindow } = require('electron')
const path = require('path')

let mainWindow

function createWindow() {
    // Check if a window already exists
    if (mainWindow && !mainWindow.isDestroyed()) {
        mainWindow.focus()
        return
    }

    mainWindow = new BrowserWindow({
        width: 400,
        height: 800,
        resizable: false,
        alwaysOnTop: true,
        frame: true, // Set to true to allow closing the window
        titleBarStyle: 'default',
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            webSecurity: true
        },
        show: false // Do not show until ready
    })

    mainWindow.loadURL('https://claude.ai')

    // Show when ready
    mainWindow.once('ready-to-show', () => {
        mainWindow.show()
    })

    // Clear reference when closed
    mainWindow.on('closed', () => {
        mainWindow = null
    })
}

app.whenReady().then(() => {
    createWindow()

    // On macOS, recreate window when the dock icon is clicked
    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow()
        }
    })
})

// Exit when all windows are closed (except on macOS)
app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit()
    }
})

// Prevent multiple instances
app.on('second-instance', () => {
    if (mainWindow) {
        if (mainWindow.isMinimized()) mainWindow.restore()
        mainWindow.focus()
    }
})

const gotTheLock = app.requestSingleInstanceLock()
if (!gotTheLock) {
    app.quit()
}
