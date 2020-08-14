console.log(`CURRENT RUNTIME: ${process.env.REACT_APP_RUNTIME_PLATFORM}`);

export const isElectron = process.env.REACT_APP_RUNTIME_PLATFORM === 'electron'

export const platform = process.env.REACT_APP_RUNTIME_PLATFORM as string;