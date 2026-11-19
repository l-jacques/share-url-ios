// Right-click "Send to Share URL" on a page, link or video, like the iOS share sheet.
import { sendURL, getResolution } from "./api.js";

const MENU_ID = "share-url-send";

chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: MENU_ID,
    title: "Send to Share URL",
    contexts: ["page", "link", "video", "audio"],
  });
});

chrome.contextMenus.onClicked.addListener(async (info, tab) => {
  if (info.menuItemId !== MENU_ID) return;
  const url = info.linkUrl || info.srcUrl || info.pageUrl || tab?.url;
  if (!url) return;
  try {
    await sendURL(url, await getResolution());
    notify("Sent", url);
  } catch (err) {
    notify("Failed to send", err.message || String(err));
  }
});

function notify(title, message) {
  chrome.notifications.create({
    type: "basic",
    iconUrl: "icons/icon128.png",
    title: `Share URL — ${title}`,
    message,
  });
}
