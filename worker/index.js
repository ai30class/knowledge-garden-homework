// 知識小花園 garden.ai30class.com 的小程式（2026-10-30 加）：只做一件事——http 一律轉成 https。
// 原因：沒加 s 的網址原本直接用 http 顯示頁面，Safari（尤其私密瀏覽）會在網址列標「不安全」（Janice 回報）。
// 其他請求原封不動交給靜態檔案（ASSETS）；不存在的網址由 ASSETS 回 404。
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.protocol === 'http:') {
      url.protocol = 'https:';
      return Response.redirect(url.toString(), 301);
    }
    return env.ASSETS.fetch(request);
  }
};
