#! /bin/bash

if [ "$1" = "calc"  ] || [ "$1" = "c"  ]
then
    rake "calc[$2]"
elif [ "$1" = "regions"  ] || [ "$1" = "r"  ]
then
    rake "regions[$2]"
elif [ "$1" = "machines"  ] || [ "$1" = "m"  ]
then
    rake "machines[$2]"
else
    echo 'helo'
fi
