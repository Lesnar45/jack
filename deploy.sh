#!/bin/bash
cecho() {
        local code="\033["
        case "$1" in
                black  | bk) color="${code}0;30m";;
                red    |  r) color="${code}1;31m";;
                green  |  g) color="${code}1;32m";;
                yellow |  y) color="${code}1;33m";;
                blue   |  b) color="${code}1;34m";;
                purple |  p) color="${code}1;35m";;
                cyan   |  c) color="${code}1;36m";;
                gray   | gr) color="${code}0;37m";;
                *) local text="$1"
        esac
        [ -z "$text" ] && local text="$color$2${code}0m"
        echo -e "$text"
}


author () {
clear
cat << "EOF"
▒█▀▀▀█ █▀▀▄ █▀▀█ █▀▀█ █▀▀ █ █▀▀
░▀▀▀▄▄ █░░█ █▄▄█ █░░█ █▀▀ ░ ▀▀█
▒█▄▄▄█ ▀░░▀ ▀░░▀ █▀▀▀ ▀▀▀ ░ ▀▀▀

▒█▀▀▄ █▀▀ █▀▀█ █░░ █▀▀█ █░░█ █▀▀ █▀▀█
▒█░▒█ █▀▀ █░░█ █░░ █░░█ █▄▄█ █▀▀ █▄▄▀
▒█▄▄▀ ▀▀▀ █▀▀▀ ▀▀▀ ▀▀▀▀ ▄▄▄█ ▀▀▀ ▀░▀▀                EOF
EOF
}
author
ehome="$(echo $HOME)"
eapt="$(which apt 2>/dev/null)"
ednf="$(which dnf 2>/dev/null)"
epac="$(which pacman 2>/dev/null)" 

echo
if [ "$ehome" == "/data/data/com.termux/files/home" ]; then
    cecho g "Termux is Detected | Installing Heroku" && \
    pkg update && pkg install -y git tsu python nodejs yarn expect &&  npm i npm@latest -g && npm i yarn -g && yarn global add heroku
    if [ ! -d ~/storage ]; then
        cecho r "Setting up storage access for Termux"
        termux-setup-storage
        sleep 2
    fi
elif [ "$epac" == "/usr/bin/pacman" ]; then
    cecho g "your os is arch based | Installing Heroku" && \
    sudo pacman -Syy && sudo pacman --noconfirm -S git python npm expect && sudo npm i npm@latest -g && sudo npm install -g heroku


elif [ "$eapt" == "/usr/bin/apt" ]; then 
    cecho g "your os is Debian/Ubuntu based | Installing Heroku" && \
    sudo apt update && sudo apt install -y unzip git python3 npm expect && sudo npm i npm@latest -g  && sudo npm install -g heroku
elif [ "$ednf" == "/usr/bin/dnf" ]; then
    cecho g "your os is fedora based | Installing required packages for Heroku"
    sudo dnf check-update && sudo dnf install -y git python3 npm expect && sudo npm i npm@latest -g && sudo npm install -g heroku
fi


while :
do
cat << EOF
1) Delete old app & recreate with same app name (sometimes helps to bypass repo bans by heroku)
2) Create new app
3) Press 3 to Quit after you succesfully Creating app
EOF
echo
read -e -p "Choose an option [1/2/3] : " oof

if [ "$oof" == "1" ]; then
    cecho y "Authorizing Heroku Cli"
    heroku login -i
    heroku apps
    read -e -p "Enter app name from the list of Apps Shown Above : " app
    heroku apps:destroy "$app" --confirm "$app"
    heroku create "$app"
    break
elif [ "$oof" == "2" ]; then
       while :
       do
        cecho y "Authorizing Heroku Cli"
        heroku login -i
        echo "Enter Unique App Name : "
        read app
        echo
cat << EOF
1) us
2) eu
EOF
echo
read -e -p "Choose your app server region [1/2] : " opt
echo
case $opt in
1)
   cecho y "Creating app in US server"
   heroku apps:create -a "$app" --region us
   status=$?
            if test $status -eq 0; then
               break
            fi
  ;;
2)
   cecho y "Creating app in EU server"
   heroku apps:create -a "$app" --region eu
   status=$?
            if test $status -eq 0; then
               break
            fi
  ;;
esac

       done
elif [ "$oof" == "3" ]; then
    break
fi
done

while :
do
        
cecho r
cat << EOF
1) public git repository
2) Its my private git repository
EOF
echo
read -e -p "Choose your git repository type [1/2] : " tpo
echo
case $tpo in
1)
   cecho g "Cloning your Public git repository"
   cecho p "Enter your public repository url: "
   read public
   read -r -p "Enter Git username : " user
   echo
   read -r -p "Enter Git email : " ghmail
   echo
   git config --global user.email ${ghmail}
   git config --global user.name ${user}
   git clone "$public" "$app" && cd "$_"
   status=$?
            if test $status -eq 0; then
               break
            fi
  ;;
2)
   cecho g "Cloning your Private git Repository"
   read -r -p "Enter Git username : " user
   echo
   read -r -p "Enter Git email : " ghmail
   echo
   read -r -p "Enter Git repo (Example:- heroku-bot) : " repo
   echo
   read -r -s -p "Git password or personal access token : " token
   echo
   git config --global user.email ${ghmail}
   git config --global user.name ${user}
   git config --global credential.helper store
   echo "https://"$user":"$token"@github.com" > ~/.git-credentials

   git clone https://github.com/"$user"/"$repo".git "$app" && cd "$_"

   
   status=$?
            if test $status -eq 0; then
               break
            fi
  ;;
esac

done

cecho p "Creating app stack as container"
while :
do
   if [ -e Dockerfile ]
   then
        echo "ok"
        heroku stack:set container -a "$app"
        break
   else
        echo "Dockerfile is not detected setting stack as  Heroku-20 by default"
        break
   fi
done


while [[ ! "$add" =~ ^[yYnN]$ ]]

do


   read -r -p "Do you want to add Environmental variables? [y/N] " response
   if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
   then
    echo " Enter variables seperated with space [ Example:- telegram_id=xxxxx tel-api=xxxx tel_bot_token=xxxx]"
    read -a arr -p "Enter Variables: "
    read -r -p "Would you like to continue  [Y/N] : " response
           if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
           then
              heroku config:set $(echo "${arr[@]}") -a "$app"
              break
           elif [[ "$response" =~ ^([nN][oO]|[nN])$ ]]
              then
                  read -r -p "Do you want to correct vars? [y/N] " response
                  if [[ "$response" =~ ^([nN][oO]|[nN])$ ]]
                     then
                          break
                  else
                     echo " This is your last chance enter all variables correctly "
                     read -a trr -p "Enter Variables: "
                     heroku config:set $(echo "${trr[@]}") -a "$app"
                     break
                  fi
           else


                  break
           fi
    else
      break
    fi
done

echo lol

cecho g "Configuring Environmental variables done"




cecho p "Now let's Choose Addons to your app(for eg:for postgreql type-> heroku-postgresql)"
while [[ ! "$add" =~ ^[yYnN]$ ]]

do


   read -r -p "Do you need any addon? [y/N] " response
   if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
   then
    cecho g "Enter addon name: "
    read var
    read -r -p "Would you like to continue  [Y/N] : " i
    case $i in
        [yY])
            echo -e "Creating addon"
            heroku addons:create "$var" -a "$app"
            break;;
        [nN])
            echo -e "No add-on supplied"
            break;;
        *)
            cecho r "Invalid Option"
            ;;
    esac
    
    else
       break
    fi
done


cecho g " Starting app "
rm -rf .git
rm .gitignore
git init
git add -f .
git commit -m "initial commit"
heroku git:remote -a "$app"
git push heroku master
while :
do
read -r -p "Do you want to Deploy? [y/N] " resp
  if [[ "$resp" =~ ^([yY][eE][sS]|[yY])$ ]]
   then
        cecho r "Please choose your apps process(Check your repo's "

        cat << EOF
1) Web
2) worker
3) Press 3 to Quit if u have a doubt(check heroku.yml or procfile or ask your bots developer in case of doubt)
EOF
echo
read -e -p "Choose an option [1/2/3] : " ort
        if [ "$ort" -eq "1" ]; then
           cecho y  "Your App is Deploying as Web App"
           heroku ps:scale web=1 -a "$app"
           break
      elif [ "$ort" -eq "2" ]; then
           cecho y  "Your App is Deploying as Web App"
           heroku ps:scale web=1 -a "$app"
           break
      elif [ "$ort" -eq "3" ]; then
           cecho p "Dont worry if u dont know ,recheck your Heroku.yml or Procfile or Contact your Bots Developer"
           cecho c "Your heroku App is already pushed"
           cecho r "script is exiting now"
           cecho y "No need to re-run script as your app is already pushed to Heroku just type the below command"
           cecho y "heroku ps:scale <web or worker> <app name>"
           break

      fi    
   else
        break
   fi      
 done
cecho  g "Successfully Task completed"
