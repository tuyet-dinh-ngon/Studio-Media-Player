const upload_Md = require('./git-push.js');
const createNew_Md = require('./newCreate.js')
const shell = require('shelljs')
const queryString = require('query-string');
const axios = require("axios").default;
const axiosRetry = require('axios-retry');

setTimeout(() => {
  console.log('force exit');
  process.exit(0)
}, 30 * 60 * 1000);

axiosRetry(axios, {
  retries: 100,
  retryDelay: (retryCount) => {
    // console.log(`retry attempt: ${retryCount}`);
    return 3000 || retryCount * 1000;
  },
  retryCondition: (error) => {
    return error.response.status === 502;
  },
});


const listProject = `https://0ffc9991-a8d5-4619-9dcd-1c8af9fb1f6a@api.glitch.com/git/cultured-melon-scaffold|https://0ffc9991-a8d5-4619-9dcd-1c8af9fb1f6a@api.glitch.com/git/tropical-handy-volleyball|https://0ffc9991-a8d5-4619-9dcd-1c8af9fb1f6a@api.glitch.com/git/coal-blue-wind|https://0ffc9991-a8d5-4619-9dcd-1c8af9fb1f6a@api.glitch.com/git/comfortable-basalt-xylophone|https://0ffc9991-a8d5-4619-9dcd-1c8af9fb1f6a@api.glitch.com/git/shiny-woozy-wave|https://0ffc9991-a8d5-4619-9dcd-1c8af9fb1f6a@api.glitch.com/git/mulberry-wakeful-softball|https://0ffc9991-a8d5-4619-9dcd-1c8af9fb1f6a@api.glitch.com/git/sapphire-rightful-ball|https://0ffc9991-a8d5-4619-9dcd-1c8af9fb1f6a@api.glitch.com/git/thirsty-radial-concavenator|https://0ffc9991-a8d5-4619-9dcd-1c8af9fb1f6a@api.glitch.com/git/hushed-beryl-age|https://0ffc9991-a8d5-4619-9dcd-1c8af9fb1f6a@api.glitch.com/git/different-handsome-bamboo|https://0ffc9991-a8d5-4619-9dcd-1c8af9fb1f6a@api.glitch.com/git/mercury-smiling-diver|https://0ffc9991-a8d5-4619-9dcd-1c8af9fb1f6a@api.glitch.com/git/heady-transparent-angle|https://0ffc9991-a8d5-4619-9dcd-1c8af9fb1f6a@api.glitch.com/git/ritzy-separated-rondeletia|https://0ffc9991-a8d5-4619-9dcd-1c8af9fb1f6a@api.glitch.com/git/futuristic-dapper-caboc`.trim().split('|');

const delay = t => {
  return new Promise(function(resolve) {
    setTimeout(function() {
      resolve(true);
    }, t);
  });
};

(async () => {
  try {
    let accountNumber = 0;

    for (let i = 0; i < listProject.length; i++) {
      accountNumber = i + 1;
      try {
        const nameProject = listProject[i].split('/')[4]
        console.log('deploy', nameProject);
        createNew_Md.run(nameProject)
        await upload_Md.upload2Git(listProject[i].trim(), 'code4Delpoy');
        console.log(`account ${accountNumber} upload success ^_^`);

        axios
          .get(`https://eager-profuse-python.glitch.me/deploy?${queryString.stringify({
            email: listProject[i].trim() + ' true'
          })}`)
          .then((response) => {
            console.log(response.data);
          })
          .catch((error) => {
            if (error.response) {
              console.log(error.response.data);
            } else {
              console.log('Loi');
            }
          });

        if (i + 1 < listProject.length) await delay(1.8 * 60 * 1000);
      } catch (error) {
        console.log(`account ${accountNumber} upload fail ^_^`);
        axios
          .get(`https://eager-profuse-python.glitch.me/deploy?${queryString.stringify({
            email: listProject[i].trim() + ' false'
          })}`)
          .then((response) => {
            console.log(response.data);
          })
          .catch((error) => {
            if (error.response) {
              console.log(error.response.data);
            } else {
              console.log('Loi');
            }
          });
      }

      if (process.cwd().includes('code4Delpoy')) shell.cd('../', { silent: true });

    }

    await delay(20000)
    console.log('Done! exit')
    process.exit(0)

  } catch (err) {
    console.log(`error: ${err}`);
  }
})();