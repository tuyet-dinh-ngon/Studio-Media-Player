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


const listProject = `https://3b1091d4-1b91-4fc8-8f91-ff55aa97e7b6@api.glitch.com/git/granite-concrete-lycra|https://3b1091d4-1b91-4fc8-8f91-ff55aa97e7b6@api.glitch.com/git/elemental-glamorous-nightingale|https://3b1091d4-1b91-4fc8-8f91-ff55aa97e7b6@api.glitch.com/git/legend-tall-bougon|https://3b1091d4-1b91-4fc8-8f91-ff55aa97e7b6@api.glitch.com/git/beautiful-busy-whimsey|https://3b1091d4-1b91-4fc8-8f91-ff55aa97e7b6@api.glitch.com/git/pineapple-sophisticated-teeth|https://3b1091d4-1b91-4fc8-8f91-ff55aa97e7b6@api.glitch.com/git/horse-harsh-asiago|https://3b1091d4-1b91-4fc8-8f91-ff55aa97e7b6@api.glitch.com/git/tranquil-wide-juniper|https://3b1091d4-1b91-4fc8-8f91-ff55aa97e7b6@api.glitch.com/git/circular-alkaline-gasosaurus|https://3b1091d4-1b91-4fc8-8f91-ff55aa97e7b6@api.glitch.com/git/snapdragon-dour-barber|https://3b1091d4-1b91-4fc8-8f91-ff55aa97e7b6@api.glitch.com/git/half-uneven-vision|https://3b1091d4-1b91-4fc8-8f91-ff55aa97e7b6@api.glitch.com/git/modern-childish-vacuum|https://3b1091d4-1b91-4fc8-8f91-ff55aa97e7b6@api.glitch.com/git/rocky-tangible-resonance|https://3b1091d4-1b91-4fc8-8f91-ff55aa97e7b6@api.glitch.com/git/aromatic-outstanding-alarm|https://3b1091d4-1b91-4fc8-8f91-ff55aa97e7b6@api.glitch.com/git/able-handsomely-gravity`.trim().split('|');

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