const { PythonShell } = require("python-shell");

module.exports = function runPythonModel() {
  return new Promise((resolve, reject) => {
    let options = {
      scriptPath: __dirname,
      pythonOptions: ["-u"],
      args: []
    };

    PythonShell.run("model.py", options)
      .then(results => {
        resolve(results[0]); // أول سطر من ناتج Python
      })
      .catch(err => {
        reject(err);
      });
  });
};
