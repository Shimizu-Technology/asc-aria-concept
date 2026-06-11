import fs from 'node:fs'
import puppeteer from 'puppeteer-core'

const explicitChromePath = process.env.CHROME_PATH || process.env.PUPPETEER_EXECUTABLE_PATH

const defaultChromeCandidates = [
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  '/Applications/Chromium.app/Contents/MacOS/Chromium',
  '/usr/bin/google-chrome',
  '/usr/bin/google-chrome-stable',
  '/usr/bin/chromium',
  '/usr/bin/chromium-browser',
  process.env.PROGRAMFILES && `${process.env.PROGRAMFILES}\\Google\\Chrome\\Application\\chrome.exe`,
  process.env['PROGRAMFILES(X86)'] && `${process.env['PROGRAMFILES(X86)']}\\Google\\Chrome\\Application\\chrome.exe`,
  process.env.LOCALAPPDATA && `${process.env.LOCALAPPDATA}\\Google\\Chrome\\Application\\chrome.exe`,
].filter(Boolean)

function resolveChromePath() {
  if (explicitChromePath) {
    if (fs.existsSync(explicitChromePath)) return explicitChromePath

    throw new Error(
      `Chrome executable not found at ${explicitChromePath}. Set CHROME_PATH to your Chrome/Chromium executable path.`,
    )
  }

  const discoveredPath = defaultChromeCandidates.find((candidate) => fs.existsSync(candidate))
  if (discoveredPath) return discoveredPath

  throw new Error(
    'Chrome executable not found. Install Chrome/Chromium or set CHROME_PATH to the browser executable before running screenshot/check scripts.',
  )
}

export function launchBrowser() {
  return puppeteer.launch({
    executablePath: resolveChromePath(),
    headless: true,
    args: ['--no-sandbox'],
  })
}
