# Auto-generated by IDE. All changes by user will be lost!
# Created at 09.01.13 14:08

BASEDIR = $$_PRO_FILE_PWD_

INCLUDEPATH +=  \
    $$BASEDIR/src

SOURCES +=  \
    $$BASEDIR/src/MagicPhotos.cpp \
    $$BASEDIR/src/decolorizeeditor.cpp \
    $$BASEDIR/src/main.cpp \
    $$BASEDIR/src/messagebox.cpp \
    $$BASEDIR/src/recoloreditor.cpp \
    $$BASEDIR/src/sketcheditor.cpp

HEADERS +=  \
    $$BASEDIR/src/MagicPhotos.hpp \
    $$BASEDIR/src/decolorizeeditor.h \
    $$BASEDIR/src/messagebox.h \
    $$BASEDIR/src/recoloreditor.h \
    $$BASEDIR/src/sketcheditor.h

CONFIG += precompile_header
PRECOMPILED_HEADER = $$BASEDIR/precompiled.h

lupdate_inclusion {
    SOURCES += \
        $$BASEDIR/../assets/*.qml
}

TRANSLATIONS = \
    $${TARGET}.ts

