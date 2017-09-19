exports.handler = function (event, context, callback) {
  console.log("Event: ", JSON.stringify(event, null, "\t"));
  console.log("Context: ", JSON.stringify(context, null, "\t"));

  const record = event.Records[0];
  if (!record) throw new Error("No record");

  const region = record.awsRegion;
  const bucket = record.s3.bucket.name;
  const file = record.s3.object.key;

  console.log("https://s3-" + region + ".amazonaws.com/" + bucket + "/" + file);

  callback(null);
};
