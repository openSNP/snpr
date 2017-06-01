# Our Roadmap

Hey there! Thanks so much for the interest in openSNP and what we're trying to accomplish over the next weeks and months.

We have some ongoing efforts which need to be done as well as some bug fixes and new features we'd love to implement. If you think we should focus on something else: Please just comment, add it or talk to us, whatever you feel like doing!

For each task we list the knowledge needed to solve the task at the end in parentheses.

## Ongoing Efforts
These are tasks that have no fixed end and that can always be worked on, and should always be somewhat on our mind.

* Getting more contributors (that might be you!)
* [Fixing our bad spelling and grammar](https://github.com/openSNP/snpr/issues/239)

## Near future (~1-2 months)
These are issues that should be done rather soon, either because they are urgent or because they can be solved rather easily.
- [ ] [Fitbit-API will break](https://github.com/openSNP/snpr/issues/252) **urgent** We've had Fitbit-support for a couple of years now. But they will change their API, breaking our integration. As it's a valuable data source we should make sure we keep it running. (Required Knowledge: Ruby/Rails gems, APIs, OAuth)
- [ ] [Fix Mediawiki integration](https://github.com/openSNP/snpr/issues/258) We're using an outdated Gem for connecting to the Mediawiki of SNPedia, so that may break in the near future. (Required Knowledge: Ruby/Rails gems, APIs)
- [ ] [Fix broken autocomplete](https://github.com/openSNP/snpr/issues/223) The UI breaks when entering phenotypes. This makes it harder/more frustrating for people to enter new data. (Required Knowledge: JavaScript)
- [ ] [Fix broken variations not entered](https://github.com/openSNP/snpr/issues/176) Same thing as for the autocomplete. (Required Knowledge: JavaScript)
- [ ] [Overhaul CSS](https://github.com/openSNP/snpr/issues/264) Right now we're using Bootstrap 2 for the CSS, it's outdated and does not play nicely with mobile devices. We should go responsive and allow people to do genetics on their phones. (Required Knowledge: CSS, JavaScript)

## Long Term (~6 months)
These issues are up next to be worked on! This is a good place to jump in if you want to help with some of our heavier tasks:
- [ ] [Link snps <-> phenotypes](https://github.com/openSNP/snpr/issues/242) So far there is no explicit link of the papers we have for given genetic variants to phenotypes. Which makes it hard for new users to find their way around from genetics to traits and vice versa. Just by linking via keywords found in the papers this could be fixed, drastically improving the usability. (Required Knowledge: Ruby/Rails)
- [ ] [upload files from a url](https://github.com/openSNP/snpr/issues/249) Soon people will have access to full genomes, but uploading this data through a web browser is a pain (it's already hard for the genotyping). So allowing people to enter the download-link which we could use to pull data in would benefit every uploading user. (Required Knowledge: Ruby/Rails, Paperclip gem)
- [ ] [Unify commenting system](https://github.com/openSNP/snpr/issues/143) Our commenting system is rather fragmented, making working on it and using it rather cumbersome; unifying it would make maintaining much easier. (Required Knowledge: Ruby/Rails)
- [ ] [Simplyfing the message system](https://github.com/openSNP/snpr/issues/149) Currently our message system is pretty oldschool. We should take this to the next level, so more users feel like using it. (Required Knowledge: Ruby/Rails)
