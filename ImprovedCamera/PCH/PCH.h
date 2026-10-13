/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */
#pragma once

// WIN32_LEAN_AND_MEAN and NOMINMAX are defined by the vcxproj.

// Defensive guard against CP_UTF8 being defined by an earlier header.
#ifdef CP_UTF8
#    undef CP_UTF8
#endif

// CommonLib/SKSE implementation must be parsed before Windows API headers.
#pragma warning(push)
#pragma warning(disable: 4005 4200 4324)

#include <SKSE/SKSE.h>
#include <RE/Skyrim.h>

#pragma warning(pop)

// Other dependencies.
#include <xbyak/xbyak.h>
// OpenGL Mathematics 
#include <glm/glm.hpp>

// Windows API headers must follow CommonLib/SKSE.
#include <Windows.h>
#include <Psapi.h>

using namespace std::literals;

namespace stl
{
    using namespace SKSE::stl;

    void asm_replace(std::uintptr_t a_from,
                     std::size_t a_size,
                     std::uintptr_t a_to);

    template <class T>
    void asm_replace(std::uintptr_t a_from)
    {
        asm_replace(a_from, T::size,
                    reinterpret_cast<std::uintptr_t>(T::func));
    }

    template <class T>
    void write_thunk_call(std::uintptr_t a_src)
    {
        auto& trampoline = SKSE::GetTrampoline();
        SKSE::AllocTrampoline(14);
        T::func = trampoline.write_call<T::size>(a_src, T::thunk);
    }

    template <class F, class T>
    void write_vfunc()
    {
        REL::Relocation<std::uintptr_t> vtbl{ F::VTABLE[0] };
        T::func = vtbl.write_vfunc(T::index, T::thunk);
    }
}
