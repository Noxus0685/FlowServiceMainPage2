{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  Linux epoll - I/O event notification facility
              https://man7.org/linux/man-pages/man7/epoll.7.html
Creation:     Dec 2024
Updated:      Dec 2024
Version:      V10.0
EMail:        francois.piette@overbyte.be  https://www.overbyte.eu
Support:      https://en.delphipraxis.net/forum/37-ics-internet-component-suite/
Legal issues: Copyright (C) 2024 by François PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium.

              This software is provided 'as-is', without any express or
              implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software for any
              purpose, including commercial applications, and to alter it
              and redistribute it freely, subject to the following
              restrictions:

              1. The origin of this software must not be misrepresented,
                 you must not claim that you wrote the original software.
                 If you use this software in a product, an acknowledgment
                 in the product documentation would be appreciated but is
                 not required.

              2. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              3. This notice may not be removed or altered from any source
                 distribution.

              4. You must register this software by sending a picture postcard
                 to the author. Use a nice stamp and mention your name, street
                 address, EMail address and any comment you like to say.

History:
Dec 09, 2024 V10.0 Baseline.





 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit Ics.Linux.epoll;

interface

{$IFDEF POSIX}

uses
    Posix.Base,
    Posix.Signal;

const
    EPOLLIN        = $00000001; // Available for read operations.
    EPOLLPRI       = $00000002; // Urgent data available for read operations.
    EPOLLOUT       = $00000004; // Available for write operations.
    EPOLLERR       = $00000008; // Error condition happened.
    EPOLLHUP       = $00000010; // Hang up happened.
    EPOLLNVAL      = $00000020; // Invalid request: fd is not open.
    EPOLLRDNORM    = $00000040; // Equivalent to EPOLLIN
    EPOLLRDBAND    = $00000080; // Out of band data available.
    EPOLLWRNORM    = $00000100; // Out of band data.
    EPOLLWRBAND    = $00000200; // Equivalent to EPOLLOUT.
    EPOLLMSG       = $00000400; // Not used by Linux.
    EPOLLRDHUP     = $00002000; // Remote stream socket closed.
    EPOLLEXCLUSIVE = $10000000; // Set exclusive mode.
    EPOLLWAKEUP    = $20000000; // Request handling of system wakeup event.
    EPOLLONESHOT   = $40000000; // Sets the one shot behaviour.
    EPOLLET        = $80000000; // Sets the edge triggered behaviour.

    // Opcodes for epoll_ctl "op" parameter.
    EPOLL_CTL_ADD  = 1;
    EPOLL_CTL_DEL  = 2;
    EPOLL_CTL_MOD  = 3;

type
    TPoll_t = Cardinal;

    EPoll_Data = record
    case Integer of
        0: (ptr : Pointer);
        1: (fd  : Integer);
        2: (u32 : UInt32);
        3: (u64 : UInt64);
    end;
    {$IF Sizeof(EPoll_Data) <> SizeOf(UInt64)}
         {$MESSAGE Fatal 'EPoll_Data has incorrect size'}
    {$ENDIF}
    TEPoll_Data =  Epoll_Data;
    PEPoll_Data = ^Epoll_Data;

    EPoll_Event = {$IFDEF CPUX64}packed {$ENDIF}record
        Events: TPoll_t;
        Data  : TEpoll_Data;
    end;

    TEPoll_Event =  EPoll_Event;
    PEpoll_Event = ^EPoll_Event;

// Create an epoll file descriptor
// https://man7.org/linux/man-pages/man2/epoll_create.2.html
function epoll_create(size: Integer): Integer; cdecl;
    external libc name _PU + 'epoll_create';
    {$EXTERNALSYM epoll_create}

// Control interface for an epoll descriptor
// https://man7.org/linux/man-pages/man2/epoll_ctl.2.html
function epoll_ctl(epfd, op, fd: Integer; event: PEPoll_Event): Integer; cdecl;
    external libc name _PU + 'epoll_ctl';
    {$EXTERNALSYM epoll_ctl}

// Wait for an I/O event on an epoll file descriptor
// https://man7.org/linux/man-pages/man2/epoll_wait.2.html
function epoll_wait(epfd: Integer; events: PEPoll_Event; maxevents, timeout: Integer): Integer; cdecl;
    external libc name _PU + 'epoll_wait';
    {$EXTERNALSYM epoll_wait}

// Create a file descriptor for event notification
// https://man7.org/linux/man-pages/man2/eventfd.2.html
function eventfd(initval: Cardinal; flags: Integer): Integer; cdecl;
    external libc name _PU + 'eventfd';
    {$EXTERNALSYM eventfd}
{$ENDIF POSIX}

implementation

end.

