{
    "targets": [ {

	"includes": [
	    "auto.gypi",
            "final-flags.gypi"
	],

	"sources": [
            "sources/yoga/YGNodeList.cpp",
            "sources/yoga/Yoga.cpp",
            "sources/Config.cc",
            "sources/Node.cc",
            "sources/global.cc",
	    "sources/nbind.cc"
	],

        "cflags": [
            "-DNBIND"
        ],

        "include_dirs": [
            "sources"
        ]

    } ],

    "includes": [
	"auto-top.gypi"
    ]
}
