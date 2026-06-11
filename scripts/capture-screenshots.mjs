import { mkdir } from 'node:fs/promises'
import { launchBrowser } from './chrome-launcher.mjs'

const base = process.env.CHECK_URL || 'http://127.0.0.1:5173'
const outDir = process.env.SCREENSHOT_DIR || '/tmp'

await mkdir(outDir, { recursive: true })

const browser = await launchBrowser()

async function pause(ms = 350) {
  await new Promise((resolve) => setTimeout(resolve, ms))
}

async function clickByText(page, text) {
  const clicked = await page.evaluate((targetText) => {
    const candidates = [...document.querySelectorAll('button, a')]
    const el = candidates.find((node) => node.textContent?.trim().includes(targetText))
    if (!el) return false
    el.click()
    return true
  }, text)
  if (!clicked) throw new Error(`Could not click: ${text}`)
  await pause()
}

async function captureDesktop() {
  const page = await browser.newPage()
  await page.setViewport({ width: 1440, height: 1200, deviceScaleFactor: 1 })
  await page.goto(base, { waitUntil: 'networkidle0' })
  await page.screenshot({ path: `${outDir}/asc-aria-01-public-handoff.png`, fullPage: true })

  await clickByText(page, 'Continue securely')
  await page.screenshot({ path: `${outDir}/asc-aria-02-secure-auth.png`, fullPage: true })

  await clickByText(page, 'Verify and continue')
  await page.screenshot({ path: `${outDir}/asc-aria-03-secure-chat.png`, fullPage: true })

  await clickByText(page, 'Open staff dashboard')
  await page.screenshot({ path: `${outDir}/asc-aria-04-staff-needs-lookup.png`, fullPage: true })

  await clickByText(page, 'Generate ARIA draft')
  await page.screenshot({ path: `${outDir}/asc-aria-05-staff-draft-ready.png`, fullPage: true })

  await clickByText(page, 'Approve and send')
  await clickByText(page, 'Open admin/audit view')
  await page.screenshot({ path: `${outDir}/asc-aria-06-admin-audit.png`, fullPage: true })

  const metrics = await page.evaluate(() => ({
    innerWidth: window.innerWidth,
    scrollWidth: document.documentElement.scrollWidth,
    bodyScrollWidth: document.body.scrollWidth,
  }))
  console.log('desktop metrics', JSON.stringify(metrics))
  await page.close()
}

async function captureMobile() {
  const page = await browser.newPage()
  await page.setViewport({ width: 390, height: 950, isMobile: true, deviceScaleFactor: 2 })
  await page.goto(base, { waitUntil: 'networkidle0' })
  await page.screenshot({ path: `${outDir}/asc-aria-07-mobile-public.png`, fullPage: true })
  await clickByText(page, 'Continue securely')
  await clickByText(page, 'Verify and continue')
  await page.screenshot({ path: `${outDir}/asc-aria-08-mobile-secure-chat.png`, fullPage: true })
  const metrics = await page.evaluate(() => ({
    innerWidth: window.innerWidth,
    scrollWidth: document.documentElement.scrollWidth,
    bodyScrollWidth: document.body.scrollWidth,
  }))
  console.log('mobile metrics', JSON.stringify(metrics))
  await page.close()
}

await captureDesktop()
await captureMobile()
await browser.close()
console.log(`screenshots saved to ${outDir}/asc-aria-*.png`)
