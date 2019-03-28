Shared Secrets
==============

Create shares of a secret code which need to be reunited to reveal the secret.

## Usage

This is a ruby library with an associated executable

```ruby
# Create 7 shares of the password which require at least 3 to recreate
Secret.create("Howdy, partner!", shares: 7, required: 3)
# => [
        [0] "1-1112273582787975695074844380307169353741255382365",
        [1] "2-1875991816751276345070115490824050279206167488551",
        [2] "3-2886525393117596696571705091964438315320864997297",
        [3] "4-4143874311886936749579613183728333462085347908603",
        [4] "5-5648038573059296504093839766115735719499616222469",
        [5] "6-7399018176634675960114384839126645087563669938895",
        [6] "7-9396813122613075117641248402761061566277509057881"
    ]

# Combine the shares to restore the secret
Secret.restore(Secret.create("Howdy, partner!", shares: 7, required: 3))
# => "Howdy, partner!"

# The secret cannot be restored with too few shares
Secret.restore(Secret.create("Howdy, partner!", shares: 7, required: 3).take(2))
# => Secret::FailedDecodeError
```


```bash
# Create 7 shares of the password which require at least 3 to recreate
$ secret create 7 3 "Howdy, partner!"
1-1026197645290506249894399987748734333070887531064
2-1519067637302214266153992634504989515382450532105
3-2073980667262818795364669700682561085860817681862
4-2690936735172319837526431186281449044505988980335
5-3369935841030717392639277091301653391317964427524
6-4110977984838011460703207415743174126296744023429
7-4914063166594202041718222159606011249442327768050

# Combine the shares to restore the secret
$ secret create 7 3 "Howdy, partner!" | xargs secret restore
Howdy, partner!

# The secret cannot be restored with too few shares
$ secret create 7 3 "Howdy, partner!" | tail -2 | xargs secret restore
Unable to decode input
```


# Create

This encoding is based on a 2048-bit prime and has a message space around 192 bytes.

## Under the Hood

This project was inspired by a homework assignment in EECS 376 (Foundations of Computer Science) at the University of Michigan.

Given the parameters of a secret, a number of shares, and a number of required shares, it's possible to generate a polynomial which has the secret as a y-intercept. To generate password shares, simply pull (x, y) coordinates from the equation. You can then reconstruct the polynomial and recover the secret using those coordinates and [Lagrange interpolation](https://en.wikipedia.org/wiki/Lagrange_polynomial).

This library accepts strings as secrets and encodes them as numbers which can be used in the equation. On decode, it reconstructs the polynomial, extracts the secret, and converts it back to a string.

## Problems

1. Occasionally a partial recovery is possible with fewer than required shares.

   ```bash
   $ secret create 7 3 "Howdy, partner!" | tail -2 | xargs secret restore
   X_wdy, partner!
   ```

   This does require at least 2 shares, and only occurs rarely, but is still a vulnerability. I have not had success consistently reproducing this.
2. This code relies on extensions of Ruby standard library classes Integer and Array. A good implementation wouldn't do that.
