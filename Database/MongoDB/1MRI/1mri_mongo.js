const fs = require("fs");
const mongodb = require("mongodb").MongoClient;
const fastimp = require("fast-csv");

// Start timing
const startTime = process.hrtime();

// Mongodb connection string
let url = "mongodb://insanedba:insane@192.168.1.31:27001/test";
let stream = fs.createReadStream("measurements.txt");
let statData = [];
let fastream = fastimp
  .parse({delimiter: ';'})
  .on("data", function(data) {
    statData.push({
      station_name: data[0],
      measurement: data[1]
    });
  })
  .on("end", function() {

    mongodb.connect(
      url,
      { useNewUrlParser: true, useUnifiedTopology: true},
      (err, client) => {
        if (err) throw err;

        client
          .db("test")
          .collection("posts")
          .insertMany(statData, (err, res) => {
            if (err) throw err;

            console.log(`Inserted: ${res.insertedCount} rows`);

            // End timing
            const endTime = process.hrtime(startTime);
            const elapsedSeconds = endTime[0];
            const elapsedNanoseconds = endTime[1];
            const elapsedTimeInMilliseconds = (elapsedSeconds * 1000) + (elapsedNanoseconds / 1000000);
            console.log(`Operation took: ${elapsedTimeInMilliseconds} milliseconds`);
            client.close();
          });
      }
    );
  });

stream.pipe(fastream);

