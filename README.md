<img src="https://www.seven.io/wp-content/uploads/Logo.svg" width="250" />


# Zammad Package for seven.io

Tested with Zammad v6.x.

## Installation
1. Download **seven-sms.szpm** file from [Latest Releases](https://github.com/seven-io/zammad/releases/latest "Latest Releases")
2. Open up your Zammad **Dashboard**
3. Click on **Admin**, navigate to **Manage->System->Packages** and press **Choose File**
4. Locate the downloaded **seven-sms.szpm** and click **Install Package**
5. Execute as *zammad* user: `zammad run rake zammad:package:migrate && zammad run rake assets:precompile && systemctl restart zammad`
6. Go to **Manage->Channels->SMS->SMS Notification** and choose **seven**
7. Type in your [API Key](https://help.seven.io/en/api-key-access), test and you are ready to go

### Support

Need help? Feel free to [contact us](https://www.seven.io/en/company/contact/).

[![MIT](https://img.shields.io/badge/License-MIT-teal.svg)](LICENSE)