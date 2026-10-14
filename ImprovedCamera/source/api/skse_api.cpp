/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

// Precompiled Header
#include "PCH.h"

#include "api/skse_api.h"

#include "plugin.h"
#include "skyrimse/ImprovedCameraSE.h"
#include "utils/Log.h"
#include "version.h"

#if 0
#include "api/versionlibdb.h"

bool DumpSpecificVersion()
{
	VersionDb db;

	// Try to load database of version 1.6.1170.0 regardless of running executable version.
	if (!db.Load(1, 6, 1170, 0))
	{
		LOG_CRITICAL("Failed to load database for 1.6.1170.0!");
		return false;
	}

	// Write out a file called 1.6.1170-offsets.txt where each line is the ID and offset.
	db.Dump("1.6.1170.0-offsets.txt"); // Dumps to root of Skyrim directory
	LOG_INFO("Dumped offsets for 1.6.1170.0");
	return true;
}
#endif

namespace SKSE {

	void SKSEMessageHandler(SKSE::MessagingInterface::Message* message)
	{
		auto plugin = DLLMain::Plugin::Get();

		switch (message->type)
		{
			case SKSE::MessagingInterface::kPostPostLoad:
			{
				plugin->SkyrimSE()->Camera()->RequestAPIs();
				break;
			}
			case SKSE::MessagingInterface::kPostLoadGame:
			{
				plugin->SkyrimSE()->LoadGame();
				break;
			}
			case SKSE::MessagingInterface::kInputLoaded:
			{
				plugin->CreateMenu();
				break;
			}
			case SKSE::MessagingInterface::kDataLoaded:
			{
				plugin->SkyrimSE()->Camera()->DetectMods();

				if (plugin->Config()->ModuleData().iMenuMode > Systems::Window::UIDisplay::kNone)
				{
					plugin->SkyrimSE()->InstallInput();

					if (plugin->Graphics()->IsInitalized())
						plugin->m_GraphicsInitialized = true;
				}
				break;
			}
		}
	}

	SKSE_API bool SKSEPlugin_Load(const SKSE::LoadInterface* skse)
	{
		auto plugin = DLLMain::Plugin::Get();
		plugin->m_Logging.Initialize();
#if 0
		DumpSpecificVersion();
#endif
		SKSE::Init(skse);

        // Reserve executable memory for the generated hook patches (Hooks.cpp).
        // This must happen before any hook calls trampoline.allocate().
        SKSE::AllocTrampoline(1 << 14);  // 16 KiB

		bool loaded = plugin->Load();

		if (loaded)
		{
			auto msgInterface = SKSE::GetMessagingInterface();
			msgInterface->RegisterListener(SKSEMessageHandler);
			plugin->SkyrimSE()->OnLoad();
		}
		return loaded;
	}

}
