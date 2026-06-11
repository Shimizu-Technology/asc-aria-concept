import { mkdir } from 'node:fs/promises'
import { launchBrowser } from './chrome-launcher.mjs'

const base = process.env.CHECK_URL || 'http://127.0.0.1:5173'
const outDir = process.env.SCREENSHOT_DIR || '/tmp'

await mkdir(outDir, { recursive: true })

const browser = await launchBrowser()

async function pause(ms = 350) {
  await new Promise((resolve) => setTimeout(resolve, ms))
}

async function warmLazyImages(page) {
  await page.evaluate(async () => {
    const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms))
    const step = Math.max(window.innerHeight * 0.85, 500)
    const maxScroll = document.documentElement.scrollHeight

    for (let y = 0; y < maxScroll; y += step) {
      window.scrollTo(0, y)
      await delay(50)
    }

    window.scrollTo(0, document.documentElement.scrollHeight)
    await delay(100)

    const images = [...document.images]
    for (const image of images) image.loading = 'eager'

    await Promise.all(
      images.map((image) => {
        if (image.complete && image.naturalWidth > 0) return Promise.resolve()

        return new Promise((resolve) => {
          const timeout = window.setTimeout(resolve, 1500)
          image.addEventListener('load', () => {
            window.clearTimeout(timeout)
            resolve()
          }, { once: true })
          image.addEventListener('error', () => {
            window.clearTimeout(timeout)
            resolve()
          }, { once: true })
        })
      }),
    )

    await Promise.all(images.map((image) => image.decode?.().catch(() => undefined) ?? Promise.resolve()))
    window.scrollTo(0, 0)
  })
  await pause(150)
}

async function captureFullPage(page, path) {
  await warmLazyImages(page)
  await page.screenshot({ path, fullPage: true })
}

async function clickByText(page, text) {
  const result = await page.evaluate((targetText) => {
    const candidates = [...document.querySelectorAll('button, a')]
    const el = candidates.find((node) => node.textContent?.trim().includes(targetText))
    if (!el) return { clicked: false, reason: 'not_found' }

    const isDisabled =
      el.matches(':disabled') ||
      el.getAttribute('aria-disabled') === 'true' ||
      el.getAttribute('disabled') !== null

    if (isDisabled) {
      return { clicked: false, reason: 'disabled', label: el.textContent?.trim() }
    }

    el.click()
    return { clicked: true }
  }, text)

  if (!result.clicked) {
    const detail = result.reason === 'disabled' ? `Matched control is disabled: ${result.label}` : 'No matching control found'
    throw new Error(`Could not click: ${text}. ${detail}`)
  }

  await pause()
}

async function captureDesktop() {
  const page = await browser.newPage()
  await page.setViewport({ width: 1440, height: 1200, deviceScaleFactor: 1 })
  await page.goto(base, { waitUntil: 'networkidle0' })
  await captureFullPage(page, `${outDir}/asc-aria-01-public-handoff.png`)

  await clickByText(page, 'Continue securely')
  await captureFullPage(page, `${outDir}/asc-aria-02-secure-auth.png`)

  await clickByText(page, 'Verify and continue')
  await captureFullPage(page, `${outDir}/asc-aria-03-secure-chat.png`)

  await clickByText(page, 'Open staff dashboard')
  await captureFullPage(page, `${outDir}/asc-aria-04-staff-needs-lookup.png`)

  await clickByText(page, 'Generate ARIA draft')
  await captureFullPage(page, `${outDir}/asc-aria-05-staff-draft-ready.png`)

  await clickByText(page, 'Approve and send')
  await clickByText(page, 'Open admin/audit view')
  await captureFullPage(page, `${outDir}/asc-aria-06-admin-audit.png`)

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
  await captureFullPage(page, `${outDir}/asc-aria-07-mobile-public.png`)
  await clickByText(page, 'Continue securely')
  await clickByText(page, 'Verify and continue')
  await captureFullPage(page, `${outDir}/asc-aria-08-mobile-secure-chat.png`)
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
