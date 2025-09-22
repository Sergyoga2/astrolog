{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 .SFNS-Regular_wdth_opsz110000_GRAD_wght1770000;\f1\fnil\fcharset0 .SFNS-Regular_wdth_opsz110000_GRAD_wght1C20000;}
{\colortbl;\red255\green255\blue255;\red255\green255\blue255;\red255\green255\blue255;\red227\green227\blue220;
}
{\*\expandedcolortbl;;\cssrgb\c100000\c100000\c99985;\cssrgb\c100000\c100000\c100000\c0;\cssrgb\c91247\c91242\c88940;
}
{\*\listtable{\list\listtemplateid1\listhybrid{\listlevel\levelnfc23\levelnfcn23\leveljc0\leveljcn0\levelfollow0\levelstartat1\levelspace360\levelindent0{\*\levelmarker \{disc\}}{\leveltext\leveltemplateid1\'01\uc0\u8226 ;}{\levelnumbers;}\fi-360\li720\lin720 }{\listname ;}\listid1}
{\list\listtemplateid2\listhybrid{\listlevel\levelnfc23\levelnfcn23\leveljc0\leveljcn0\levelfollow0\levelstartat1\levelspace360\levelindent0{\*\levelmarker \{disc\}}{\leveltext\leveltemplateid101\'01\uc0\u8226 ;}{\levelnumbers;}\fi-360\li720\lin720 }{\listname ;}\listid2}
{\list\listtemplateid3\listhybrid{\listlevel\levelnfc23\levelnfcn23\leveljc0\leveljcn0\levelfollow0\levelstartat1\levelspace360\levelindent0{\*\levelmarker \{disc\}}{\leveltext\leveltemplateid201\'01\uc0\u8226 ;}{\levelnumbers;}\fi-360\li720\lin720 }{\listname ;}\listid3}
{\list\listtemplateid4\listhybrid{\listlevel\levelnfc23\levelnfcn23\leveljc0\leveljcn0\levelfollow0\levelstartat1\levelspace360\levelindent0{\*\levelmarker \{disc\}}{\leveltext\leveltemplateid301\'01\uc0\u8226 ;}{\levelnumbers;}\fi-360\li720\lin720 }{\listname ;}\listid4}
{\list\listtemplateid5\listhybrid{\listlevel\levelnfc23\levelnfcn23\leveljc0\leveljcn0\levelfollow0\levelstartat1\levelspace360\levelindent0{\*\levelmarker \{disc\}}{\leveltext\leveltemplateid401\'01\uc0\u8226 ;}{\levelnumbers;}\fi-360\li720\lin720 }{\listname ;}\listid5}
{\list\listtemplateid6\listhybrid{\listlevel\levelnfc23\levelnfcn23\leveljc0\leveljcn0\levelfollow0\levelstartat1\levelspace360\levelindent0{\*\levelmarker \{disc\}}{\leveltext\leveltemplateid501\'01\uc0\u8226 ;}{\levelnumbers;}\fi-360\li720\lin720 }{\listname ;}\listid6}
{\list\listtemplateid7\listhybrid{\listlevel\levelnfc23\levelnfcn23\leveljc0\leveljcn0\levelfollow0\levelstartat1\levelspace360\levelindent0{\*\levelmarker \{disc\}}{\leveltext\leveltemplateid601\'01\uc0\u8226 ;}{\levelnumbers;}\fi-360\li720\lin720 }{\listname ;}\listid7}}
{\*\listoverridetable{\listoverride\listid1\listoverridecount0\ls1}{\listoverride\listid2\listoverridecount0\ls2}{\listoverride\listid3\listoverridecount0\ls3}{\listoverride\listid4\listoverridecount0\ls4}{\listoverride\listid5\listoverridecount0\ls5}{\listoverride\listid6\listoverridecount0\ls6}{\listoverride\listid7\listoverridecount0\ls7}}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab720
\pard\pardeftab720\sa120\partightenfactor0

\f0\fs32 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \cb3 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 project: Astrolog\uc0\u8232 platform: iOS\u8232 minimum_ios: 16.0\u8232 languages: Swift, SwiftUI, UIKit, Combine\u8232 design_patterns: MVVM, Coordinator, Repository, Dependency Injection\u8232 stateless_ui: true\u8232 repository_structure: Feature-first, Core isolation\
\pard\pardeftab720\sa120\partightenfactor0

\f1\fs27 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \strokec4 Description\
\pard\pardeftab720\sa120\partightenfactor0

\f0\fs32 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \strokec4 AstroWise is an iOS application for astrology, cosmic mindfulness, and social features. Key modules: birth chart calculator (SwissEphemeris C library, fallback AstrologyAPI), daily forecasts, social compatibility, meditation library, subscription monetization (PRO/GURU).\
\pard\pardeftab720\sa120\partightenfactor0

\f1\fs27 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \strokec4 Key Dependencies\
\pard\tx220\tx720\pardeftab720\li720\fi-720\sa120\partightenfactor0
\ls1\ilvl0
\f0\fs32 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 swiss_ephemeris: C library via Swift bridging header, all astrology logic\
\ls1\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 astrology_api: SaaS fallback for cloud ephemeris\
\ls1\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 charts: Apple Charts for visual data\
\ls1\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 lottie: vector animations for UI\
\ls1\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 avfoundation: audio/video for meditations and media\
\ls1\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 core_data, cloudkit: local/offline-first storage and iCloud sync\
\ls1\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 firestore, supabase (postgresql, edge functions): cloud data, real-time sync, user-level security\
\ls1\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 revenuecat, storekit_2: subscriptions, billing, purchase validation, webhooks\
\ls1\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 onesignal, fcm, apple_push: push notifications, scalable triggers, deep links\
\ls1\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 mixpanel, amplitude: analytics, user journeys, funnel\
\ls1\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 sentry, firebase_analytics: crash tracking and performance\
\ls1\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 fastlane, github_actions: CI/CD pipelines\
\ls1\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 testflight, app_store: beta and production deployments\
\ls1\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 lokalise: localization, English/Russian/Spanish default\
\pard\pardeftab720\sa120\partightenfactor0

\f1\fs27 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \strokec4 Core Architecture\
\pard\tx220\tx720\pardeftab720\li720\fi-720\sa120\partightenfactor0
\ls2\ilvl0
\f0\fs32 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Project modules by feature, every module with a README.\
\ls2\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 All business logic in /Core layer only.\
\ls2\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 View-to-ViewModel via MVVM pattern, only stateless Views permitted.\
\ls2\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Coordinators handle all navigation.\
\ls2\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Repository classes abstract API/local/cloud/database.\
\ls2\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Dependency Injection mandatory for all services.\
\pard\pardeftab720\sa120\partightenfactor0

\f1\fs27 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \strokec4 Code Style\
\pard\tx220\tx720\pardeftab720\li720\fi-720\sa120\partightenfactor0
\ls3\ilvl0
\f0\fs32 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 camelCase for variables/methods.\
\ls3\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Do not hardcode strings; use en.lproj, ru.lproj, es.lproj.\
\ls3\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Use SwiftLint and SwiftGen; default strict mode.\
\ls3\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Update CHANGELOG.md for every public API change.\
\pard\pardeftab720\sa120\partightenfactor0

\f1\fs27 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \strokec4 Workflows\
\pard\tx220\tx720\pardeftab720\li720\fi-720\sa120\partightenfactor0
\ls4\ilvl0
\f0\fs32 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Onboarding: splash, permissions, birth info collection (date, time, city).\
\ls4\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Chart generation: SwissEphemeris -> AstrologyAPI fallback.\
\ls4\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Home: daily forecast, status, shortcuts.\
\ls4\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Chart: interactive natal chart, detailed report, PDF export.\
\ls4\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Social: add friend, compare charts, share compatibility.\
\ls4\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Mindfulness: meditations sorted by mood/astro events.\
\ls4\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Profile: settings, backup, privacy, subscription management.\
\ls4\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Subscriptions: PRO/GURU unlock advanced features.\
\ls4\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Notifications: through OneSignal, FCM, Apple.\
\pard\pardeftab720\sa120\partightenfactor0

\f1\fs27 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \strokec4 Security & Privacy\
\pard\tx220\tx720\pardeftab720\li720\fi-720\sa120\partightenfactor0
\ls5\ilvl0
\f0\fs32 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 All personal data (birth info) encrypted on-device and in-cloud.\
\ls5\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Secure Keychain for credentials and secrets.\
\ls5\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 SSL pinning for all API endpoints.\
\ls5\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 All Apple/iOS privacy requirements strictly enforced.\
\pard\pardeftab720\sa120\partightenfactor0

\f1\fs27 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \strokec4 Release and Deploy\
\pard\tx220\tx720\pardeftab720\li720\fi-720\sa120\partightenfactor0
\ls6\ilvl0
\f0\fs32 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Tests: Xcode unit/UI tests required for all features.\
\ls6\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 CI: Fastlane for builds, screenshots, releases.\
\ls6\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 All deployments via App Store Connect/TestFlight.\
\ls6\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 All strings and assets localized by Lokalise workflow.\
\pard\pardeftab720\sa120\partightenfactor0

\f1\fs27 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \strokec4 Directives for Claude Code\
\pard\tx220\tx720\pardeftab720\li720\fi-720\sa120\partightenfactor0
\ls7\ilvl0
\f0\fs32 \AppleTypeServices\AppleTypeServicesF65539 \cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Follow MVVM, Coordinator, Repository everywhere.\
\ls7\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Always use SwissEphemeris for calculations, fallback to AstrologyAPI if needed.\
\ls7\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Any new feature: draft user flow \uc0\u8594  feature documentation \u8594  implement new module.\
\ls7\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 Run all tests before committing.\
\ls7\ilvl0\cf2 \kerning1\expnd0\expndtw0 \outl0\strokewidth0 {\listtext	\uc0\u8226 	}\cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec4 All backend/cloud keys in .env only, never hardcoded.\
}