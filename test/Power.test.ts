import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("Power ICO", function () {
  ``;
  async function deployOneYearLockFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, bob, jack, alice] = await hre.ethers.getSigners();

    const Power = await hre.ethers.getContractFactory("Power");
    const power = await Power.deploy();

    const PowerICO = await hre.ethers.getContractFactory("PowerTokenIco");
    const powerIco = await PowerICO.deploy(power.getAddress());

    return { powerIco, power, owner, bob, alice, jack };
  }

  it("Should mint token", async function () {
    const { power, owner } = await loadFixture(deployOneYearLockFixture);

    const ownerBalance = await power.balanceOf(owner.getAddress());
    const toalSupply = await power.totalSupply();
    expect(ownerBalance).to.equal(toalSupply);
  });

  describe("PowerTokenIco", function () {
    it("Should approve tokens for owner", async function () {
      const { power, owner, powerIco } = await loadFixture(
        deployOneYearLockFixture
      );
      const approveAmount =
        10000000000000000000000000000000000000000000000000000000000000000000000n;
      await power.approve(powerIco.getAddress(), approveAmount);

      const allowance = await power.allowance(
        owner.address,
        powerIco.getAddress()
      );
      expect(allowance).to.equal(approveAmount);
    });

    it("should change the phase", async function () {
      const { power, owner, powerIco } = await loadFixture(
        deployOneYearLockFixture
      );
      await powerIco.changePhase(1);

      const currentPhase = await powerIco.phase();
      expect(currentPhase).to.not.equal(0);
    });
  });

  it("should buy fresh tokens", async function () {
    const { power, owner, powerIco, alice } = await loadFixture(
      deployOneYearLockFixture
    );
    await power.mint();

    await power
      .connect(owner)
      .approve(
        powerIco.getAddress(),
        hre.ethers.parseEther(
          "1000000000000000000000000000000000000000000000000000"
        )
      );

    await powerIco
      .connect(alice)
      .buyTokens({ value: hre.ethers.parseEther("0.01") });

    const aliceBalance = await power.balanceOf(alice.address);
    expect(aliceBalance).to.greaterThan(0);
  });

  it("should get Rate", async function () {
    const { power, owner, powerIco } = await loadFixture(
      deployOneYearLockFixture
    );
    const rate = await powerIco.getPrice(1);
    console.log(rate);
  });

  it("should  getprice with phase", async function () {
    const { power, owner, powerIco } = await loadFixture(
      deployOneYearLockFixture
    );

    let initialPhase = await powerIco.phase();
    let initialPrice = await powerIco.getPrice;

    await powerIco.phase();
    await powerIco.getPrice;

    let currentPhase = await powerIco.phase();
    let currentPrice = await powerIco.getPrice;

    console.log("Initial Phase:", initialPhase);
    console.log("Initial Price:", initialPrice);
    console.log("Current Phase:", currentPhase);
    console.log("Current Price:", currentPrice);
  });
});
