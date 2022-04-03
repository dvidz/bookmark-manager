<?php

declare(strict_types=1);

namespace App\Dvidz\Rest\Model;

use App\Dvidz\Rest\Entity\BookmarkInterface;
use App\Dvidz\Rest\Exception\MediaTypeException;

/**
 * Class BookmarkViewModel.
 */
class BookmarkViewModel extends BookmarkModelDto implements BookmarkViewModelInterface, ViewModelInterface
{
    /**
     * @var string
     */
    public string $mediaSize;

    /**
     * @param BookmarkInterface $bookmark
     *
     * @throws MediaTypeException
     */
    private function __construct(BookmarkInterface $bookmark)
    {
        $this->url = $bookmark->getUrl();
        $this->type = null;

        if (null !== $typeLink = $bookmark->getTypeLink()) {
            $this->type = $typeLink->getTypeLinkName();
        }

        if (null !== $publicationDate = $bookmark->getPublicationDate()) {
            $this->publishedDate = $publicationDate->format('Y-m-d');
        }

        $this->providerName = $bookmark->getProviderName();
        $this->linkTitle = $bookmark->getLinkTitle();
        $this->linkAuthor = $bookmark->getLinkAuthor();

        $this->createAt = $bookmark->getCreatedAt()->format('Y-m-d');

        if ('video' === $this->type) {
            $this->mediaSize = $bookmark->getVideoSize()->getWidth().'x'.$bookmark->getVideoSize()->getHeight();
            $this->videoDuration = $bookmark->getVideoSize()->getDuration();
        } elseif ('photo' === $this->type) {
            $this->mediaSize = $bookmark->getImageSize()->getWidth().'x'.$bookmark->getImageSize()->getHeight();
        } else {
            throw new MediaTypeException('This link type is not supported.');
        }
    }

    /**
     * @param BookmarkInterface $bookmark
     *
     * @return BookmarkViewModelInterface
     *
     * @throws MediaTypeException
     */
    public static function getViewModel(BookmarkInterface $bookmark): BookmarkViewModelInterface
    {
        return new self($bookmark);
    }
}