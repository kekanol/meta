//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       load_command_linker_option.h
//!
//! @author     Milen Dzhumerov
//! @copyright  Copyright (c) 2020-2020 Milen Dzhumerov. All rights reserved.
//|
//| Permission is hereby granted, free of charge, to any person obtaining a
//| copy of this software and associated documentation files (the "Software"),
//| to deal in the Software without restriction, including without limitation
//| the rights to use, copy, modify, merge, publish, distribute, sublicense,
//| and/or sell copies of the Software, and to permit persons to whom the
//| Software is furnished to do so, subject to the following conditions:
//|
//| The above copyright notice and this permission notice shall be included
//| in all copies or substantial portions of the Software.
//|
//| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//| OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------------//

#ifndef _load_command_linker_option_h
#define _load_command_linker_option_h

//! @addtogroup LOAD_COMMANDS
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Linker Option
//! @name       Linker Option
//----------------------------------------------------------------------------//

_mk_export uint32_t
mk_load_command_linker_option_id(void);

_mk_export uint32_t
mk_load_command_linker_option_get_nstrings(mk_load_command_ref load_command);

_mk_export size_t
mk_load_command_linker_option_copy_string(mk_load_command_ref load_command, uint32_t index, char *output, size_t output_len);


#if __BLOCKS__
//! Iterate over the strings using a block.
_mk_export void
mk_load_command_linker_option_enumerate_strings(mk_load_command_ref load_command,
                                                void (^enumerator)(const char *string, uint32_t index, bool *stop));
#endif

//! @} LOAD_COMMANDS !//

#endif /* _load_command_linker_option_h */