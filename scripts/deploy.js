const hre = require("hardhat");
const fsPromises = require("fs").promises;

async function main() {
  await hre.run("compile");

  const FlappyMayhemTreasure = await hre.ethers.getContractFactory(
    "FlappyMayhemTreasury"
  );
  const flappyMayhemTreasure = await FlappyMayhemTreasure.deploy(
    "0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000",
    "0x196b0e5d437FB4c5f3C27E0Dd3E4DFe2FFeCfdAe",
    1
  );

  await flappyMayhemTreasure.deployed();
  await writeDeploymentInfo(flappyMayhemTreasure, "deployment-info");
}

async function writeDeploymentInfo(
  contract,
  filename = "",
  extension = "json"
) {
  const data = {
    network: hre.network.name,
    contract: {
      address: contract.address,
      signerAddress: contract.signer.address,
      abi: contract.interface.format(),
    },
  };
  const content = JSON.stringify(data, null, 2);
  await fsPromises.writeFile(
    "deployment_logs/".concat(
      filename,
      "_",
      new Date().toISOString().slice(0, 10),
      ".",
      extension
    ),
    content,
    {
      encoding: "utf-8",
    }
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
