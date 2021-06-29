const { ethers } = require("hardhat");
const chai = require("chai");
const { expect } = chai;

describe("Strategies", function() {
  let controller;
  let snowGlobes;
  let strategies;

  let controllerAddress;
  let snowGlobeAddresses;
  let strategyAddresses;

  let controllerABI;
  let snowGlobeABIs;
  let strategyABIs;

  this.beforeEach(async () => {
    const signer = "0xc9a51fB9057380494262fd291aED74317332C0a2";

    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [signer]}
    );

    const owner = await ethers.provider.getSigner(signer);

    controllerAddress = "0xf7b8d9f8a82a7a6dd448398afc5c77744bd6cb85";
    
    snowGlobeAddresses = {
      ""
    }

  })

  // 1. Deploy the strategy to be tested


})