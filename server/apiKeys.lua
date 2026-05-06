-- Webhook for instapic posts, recommended to be a public channel
INSTAPIC_WEBHOOK = "https://discord.com/api/webhooks/1485414744524456026/WupB_TWdXiOWEOSUrJsWw7g__0W8fDhPlInlheXS3lnI80u6xIL7zIW70i7fRrOKdsgB"
-- Webhook for birdy posts, recommended to be a public channel
BIRDY_WEBHOOK = ""

-- Discord webhook or API key for server logs
-- We recommend https://fivemanage.com/ for logs. Use code "LBLOGS" for 20% off the Logs Pro plan
LOGS = {
    Default = "", -- set to false to disable
    Calls = "",
    Messages = "https://discord.com/api/webhooks/1367216011048386651/4Uy76hVWz1I6C5-YPmT6vGIyVrdk4NXgtxTRpBny6ln48gx-lPduCLmtsHHv_t2jeV-m",
    InstaPic = "https://discord.com/api/webhooks/1485414744524456026/WupB_TWdXiOWEOSUrJsWw7g__0W8fDhPlInlheXS3lnI80u6xIL7zIW70i7fRrOKdsgB",
    Birdy = "https://discord.com/api/webhooks/1366444021404270622/nbEdM57tnb3daLiic1JVnXzY2E0o0SiswrjQKxUKw9wa0QpAdan_JWpvilgGE4kLxTlw",
    YellowPages = "",
    Marketplace = "",
    Mail = "https://discord.com/api/webhooks/1367216203654758522/fR8nY0fOM3OW1UBxd_qXqgUpwmlEYq-jvrPJR5dBG0Md1Tnw0AweI1wHUc2rHgsTedX-",
    Wallet = "",
    DarkChat = "",
    Services = "https://discord.com/api/webhooks/1366443502162018364/lNxke8YwQpMfo8EQnCcVNbMGEPZNQ1TZ0bLj44PH1bUt_lMrPNXeHO5X4Pd6D2bqm1su",
    Crypto = "",
    Trendy = "",
    Uploads = "https://discord.com/api/webhooks/1485414744524456026/WupB_TWdXiOWEOSUrJsWw7g__0W8fDhPlInlheXS3lnI80u6xIL7zIW70i7fRrOKdsgB" -- all camera uploads will go here
}

DISCORD_TOKEN = nil -- you can set a discord bot token here to get the players discord avatar for logs

-- Set your API keys for uploading media here.
-- Please note that the API key needs to match the correct upload method defined in Config.UploadMethod.
-- The default upload method is Fivemanage
-- You can get your API keys from https://fivemanage.com/
-- Use code LBPHONE10 for 10% off on Fivemanage
-- A video tutorial for how to set up Fivemanage can be found here: https://www.youtube.com/watch?v=y3bCaHS6Moc
API_KEYS = {
    Video = "xK1STu3fTGU0HOPlBiNfpGshGHzcl0od",
    Image = "xK1STu3fTGU0HOPlBiNfpGshGHzcl0od",
    Audio = "xK1STu3fTGU0HOPlBiNfpGshGHzcl0od",
}

-- Here you can set your credentials for Config.DynamicWebRTC
-- This is needed if video calls or InstaPic live streams are not working
-- You can get your credentials from https://dash.cloudflare.com/?to=/:account/realtime/turn/overview
WEBRTC = {
    TokenID = nil,
    APIToken = nil,
}
