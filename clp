#! /bin/bash

if [ "$1" = "calc"  ] || [ "$1" = "c"  ]
then
    rake "calc[$2]"
elif [ "$1" = "info"  ] || [ "$1" = "i"  ]
then
    rake "info[$2]"
elif [ "$1" = "regions"  ] || [ "$1" = "r"  ]
then
    rake "regions[$2]"
elif [ "$1" = "machines"  ] || [ "$1" = "m"  ]
then
    rake "machines[$2]"
elif [ "$1" = "lookup"  ] || [ "$1" = "l"  ]
then
    rake "lookup[$2, $3, $4]"
elif [ "$1" = "software"  ] || [ "$1" = "s"  ]
then
    rake "software[$2]"
else
    echo 'clp calc <input file>'
    echo 'clp info [aws|azure]'
    echo 'clp lookup <cores> <memory> <provider(optional)>'
fi
