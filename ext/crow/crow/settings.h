#pragma once
// settings for crow
// TODO - replace with runtime config. libucl?

// Boost.Asio 1.70+ removed io_service; Crow still uses the old name.
#include <boost/version.hpp>
#include <boost/asio/io_context.hpp>
#include <boost/asio/deadline_timer.hpp>
#if BOOST_VERSION >= 107000
namespace boost { namespace asio {
  using io_service = io_context;
}}
#endif

/* #ifdef - enables debug mode */
//#define CROW_ENABLE_DEBUG

/* #ifdef - enables logging */
#define CROW_ENABLE_LOGGING

/* #ifdef - enables ssl */
//#define CROW_ENABLE_SSL

/* #define - specifies log level */
/*
    Debug       = 0
    Info        = 1
    Warning     = 2
    Error       = 3
    Critical    = 4

    default to INFO
*/
#define CROW_LOG_LEVEL 1


// compiler flags
#if __cplusplus >= 201402L
#define CROW_CAN_USE_CPP14
#endif

#if defined(_MSC_VER)
#if _MSC_VER < 1900
#define CROW_MSVC_WORKAROUND
#define constexpr const
#define noexcept throw()
#endif
#endif
